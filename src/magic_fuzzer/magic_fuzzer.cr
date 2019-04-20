require "json"
require "uuid"

require "../xmmessage"
require "../dahua_hash"
require "../commands/*"

require "./magic_error"
require "./magic_socket"
require "./magic_report"

#TODO: CLOSE OUT SOCKET AFTER EVERY MAGIC!!!!!!!!!!!!!
class MagicFuzzer(Command)
  CLEAR_SCREEN = "\e[H\e[2J"

  private def clear_screen
    puts CLEAR_SCREEN
  end

  @factory_fiber : Fiber = spawn {}

  # Handles output
  @tick_fiber  : Fiber = spawn {}

  POOL_MAX = 32

  # Hash of MagicSocket UUID to a MagicSocket
  @socket_pool = {} of UUID => MagicSocket

  # How many replies recieved
  @successful_replies = 0

  # Unique results, hash of the message => message
  @results = {} of UInt64 => String
  # Matches what message hash was returned with what magics.
  @results_matches = {} of UInt64 => Array(UInt16)
  # What magics failed in some way.
  @bad_results = {} of UInt16 => String
  
  @factory_state = "off"

  @start_time : Time = Time.now
  MAX_TIMEOUT = 10
  MAX_RETRIES = 3
  
  CAMERA_WAIT_TIME = Time::Span.new(0, 0, 110)
  
  @last_factory_check_in : Time = Time.now

  TCP_PORT = 34567

  getter? is_running = false

  SESSION_REGEX = /,?\h?\"SessionID\"\h\:\h\"0x.{8}\"/

  @current_magic = 0

  def initialize(@magic : Enumerable = (0x0000..0x08FF), 
          @output : IO = STDOUT,
          @username = "admin", 
          @password = "",
          hash_password = true,
          @login = true,
          @target_ip = "192.168.11.109")

    @password = Dahua.digest(@password) if hash_password

    make_pool
  end

  private def make_pool
    @socket_pool = {} of UUID => MagicSocket

    POOL_MAX.times do |i|
      success = false

      until success
        begin
          socket = MagicSocket.new(@target_ip, TCP_PORT)
          @socket_pool[socket.uuid] = socket
          @socket_pool[socket.uuid].magic = 0_u16
          @socket_pool[socket.uuid].state = "free"
          @socket_pool[socket.uuid].timeout = Time.now
          success = true
        rescue e
          if e.is_a? MagicError::BaseException
            clear_screen
            puts "Waiting for camera to come online"
            puts e.inspect
          else
            raise e
          end
        end
      end
    end
  end

  private def replace_socket(old_sock, new_sock)

    new_sock.uuid = old_sock.uuid
    # Replace the socket's uuid, magic, and timeout
    # This will prevent sockets from hanging due to replacement
    @socket_pool[new_sock.uuid] = new_sock
    @socket_pool[new_sock.uuid].magic = old_sock.magic
    @socket_pool[new_sock.uuid].timeout = old_sock.timeout
    @socket_pool[new_sock.uuid].state = "replaced"
    #close the old socket
    old_sock.close

    new_sock
  end

  # returns the uuid of a free socket
  private def find_free_socket : (UUID | Nil)
    socket = (@socket_pool.find { |uuid, socket| socket.state == "free"})
    if socket
      socket[0]
    else
      nil
    end
  end

  def run
    unless is_running?
      @is_running = true
      @start_time = Time.now
      spawn_factory
      spawn_tick
    end
  end

  def close
    @socket_pool.each {|uuid, socket| socket.close}
    @is_running = false
  end

  # check in to show the factory fiber is still running / not stuck
  private def factory_check_in
    @last_factory_check_in = Time.now
  end

  # Starts a single socket job
  private def start_magic(magic)
    socket = nil
    until socket
      factory_check_in
      @factory_state = "finding socket for #{magic.to_s 16}"
      socket_uuid = find_free_socket
      socket = @socket_pool[socket_uuid]?
    end
    # If we did find a socket
    if socket

      # Bind socket to magic
      @socket_pool[socket.uuid].magic = magic.to_u16


      socket_uuid = socket.uuid

      spawn do
        #for some reason have to for
        @socket_pool[socket_uuid].state = "started"
        @socket_pool[socket_uuid].timeout = Time.now

        # Make counter variables
        success = false

        # Until:
        #   There is success or,
        #   Max number of retries reached or,
        #   Max timeout reached
        until success || (Time.now - @socket_pool[socket_uuid].timeout).to_i > MAX_TIMEOUT || !is_running?
          begin
            # Only login if we need to
            if @login
              @socket_pool[socket_uuid].state = "logging_in"
              # login, raises an error if login failed
              @socket_pool[socket_uuid].login(@username, @password)

              @socket_pool[socket_uuid].state = "logged_in"
            end

            # make the message from the command class, with the custom magic
            c = Command.new(magic: magic.to_u16)
            
            # send
            @socket_pool[socket_uuid].send_message c

            @socket_pool[socket_uuid].state = "sent_message"

            # yield to let other fibers have time
            Fiber.yield

            @socket_pool[socket_uuid].state = "recieving_message"

            # recieve reply
            m = @socket_pool[socket_uuid].recieve_message
            @socket_pool[socket_uuid].state = "recieved_message"


            # at this point we got a reply, or we raised an error
            # checks to see if the reply is unique or not
            unless @results.keys.any? {|r| r == m.message.hash}
              # Add it to the results
              @results[m.message.hash] = m.message
              # Add a new array for magic sequence results
              @results_matches[m.message.hash] = [] of UInt16
            end
            # Add out results match
            @results_matches[m.message.hash] << magic.to_u16
            # Mark socket as unused
            @successful_replies += 1
            success = true
          rescue e : MagicError::BaseException
            # output the error to the socket's state
            @socket_pool[socket_uuid].log = "spawn socket: " + e.inspect
            # Check to see if it's an error we expect
            @socket_pool[socket_uuid].state = "error"

            # Restart the socket, close, reopen, and replace it
            begin
              @socket_pool[socket_uuid].state = "reopening"
              
              # Replace the socket both in the pool, and in this fiber
              new_socket = MagicSocket.new(@target_ip, TCP_PORT)

              @socket_pool[socket_uuid].log = "spawned new socket"
              replace_socket(@socket_pool[socket_uuid], new_socket)
              @socket_pool[socket_uuid].state = "replaced"
            rescue err : MagicError::BaseException
              # The camera has crashed, so we need to wait until it comes back up
              # Move the socket time forward CAMERA_WAIT_TIME seconds, to prevent time out due to crash
              
              # This ensures that the order of sockets is randomized to ensure that if a command is causing a disconnect, that some new 
              # sockets will still be able to get through and resolve potentially.
              random_wait_time = Time::Span.new(0, 0, rand(10) + 10)
              @socket_pool[socket_uuid].timeout += random_wait_time
              @socket_pool[socket_uuid].log = "SOCKET ERROR: SLEEPING #{random_wait_time} SECONDS"
              @socket_pool[socket_uuid].state = "sleeping"
              sleep random_wait_time
            rescue err
              @socket_pool[socket_uuid].log = "replace_socket: " + err.inspect
              raise err
            end
          rescue e
            # Mark bad socket, need to figure out how to handle this gracefully
            @socket_pool[socket_uuid].log = "BAD ERROR!! " + e.inspect
            raise e
          end
          # Attempt Fiber.yield once a loop
          Fiber.yield
        end

        #Add it to the bad results
        @bad_results[magic.to_u16] = "#{@socket_pool[socket_uuid].state} : #{@socket_pool[socket_uuid].log}" unless success
        @socket_pool[socket_uuid].state = "free"
      end
    end
  end

  # Starts the fiber that handles the creation of socket jobs
  private def spawn_factory
    @factory_fiber = spawn do
      @factory_state = "on"
      # Go through each magic sequence
      @magic.each do |magic|
        @factory_state = "incrementing"

        @current_magic = magic
        # Attempt to find a free socket
        start_magic(magic)
      end

      3.times do |x|
        @bad_results.keys.shuffle.each do |magic|
          @factory_state = "bad_results_working"
          #remove it from bad_results, just in case we retried it and it worked!
          @bad_results.delete(magic.to_u16)
          spawn do
            retries = 0
            success = false

            until success || retries >= MAX_RETRIES
              start_magic(magic)

              Fiber.yield
              
              # Test to see if we succeeded, or if we failed.
              until (success = @results_matches.values.any? {|magics| magics.includes? magic}) || @bad_results.keys.includes?(magic)
                found_socket_uuid = @socket_pool.find{|uuid, socket| socket.magic == magic}
                if found_socket_uuid
                  socket = @socket_pool[found_socket_uuid[0]]
                  @socket_pool[socket.uuid].log = "Retrying bad result: #{retries}"
                  break if (Time.now - @socket_pool[found_socket_uuid].timeout).to_i > MAX_TIMEOUT
                end
              end
              retries += 1
            end

            @successful_replies += 1 if success
          end
        end
      end

      # wait until we are done with all sockets, then mark state done
      until @socket_pool.all? {|uuid, socket| socket.state == "free"}
        @factory_state =  "waiting_to_finsih"
        Fiber.yield
      end

      @factory_state = "done"
    end
  end

  # Spawns the fiber that runs the HUD tick
  private def spawn_tick
    @tick_fiber = spawn do
      while is_running?
        tick
      end
    end
  end

  # Give HUD output
  private def tick
    clear_screen
    puts "Fuzzing #{Command}"
    puts "Time: #{Time.now - @start_time}"
    puts "Current: #{@current_magic-@magic.begin}/#{@magic.size} : #{@current_magic.to_s(16)}"
    puts "Total Completion: #{(((@current_magic-@magic.begin).to_f / @magic.size.to_f)*100).round(3)}%"
    puts "Waiting for magics: "
    # Sort the sockets by their magics, so we know which magics cause the most trouble
    @socket_pool.values.sort{|a, b| a.magic <=> b.magic}.each do |socket|
      if socket
        puts "0x#{socket.magic.to_s(16).rjust(4, '0')} : #{socket.state.rjust(20, ' ')} : #{socket.log.rjust(80, ' ')} : #{socket.uuid.to_s.rjust(20, ' ')} : #{(Time.now - socket.timeout).to_s.rjust(20, ' ')}"
      end
    end
    puts
    puts "Status"
    puts "Factory: #{@factory_state}"
    puts "Last Check In: #{@last_factory_check_in}"

    puts "Total Successes: #{@successful_replies}"
    puts "Total Unique Replies: #{@results.keys.size}"
    puts "Total Bad Results: #{@bad_results.keys.size}"
    puts 
    puts "DBUG:"
    puts "total sockets: #{@socket_pool.size}"
    

    sleep 0.2
  end

  def wait_until_done
    until @factory_state == "done"
      sleep 1
    end
  end

  def report
    mr = MagicReport.new @output
    mr.make(@start_time, @results, @results_matches, @bad_results)
  end
end


