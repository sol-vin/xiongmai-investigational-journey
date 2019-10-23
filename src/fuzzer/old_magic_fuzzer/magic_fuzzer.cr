require "json"
require "uuid"
require "logger"

require "../../xmmessage"
require "../../errors"
require "../../xmsocket"
require "../../dahua_hash"
require "../../commands/*"

require "./magic_report"
require "./magic_result"

class MagicFuzzer
  CLEAR_SCREEN = "\e[H\e[2J"

  private def clear_screen
    puts CLEAR_SCREEN
  end

  LOG_FILE = File.open("./logs/magic_fuzzer_log.log", "w+")
  LOG = Logger.new LOG_FILE

  @main_fiber : Fiber = spawn {}
  @main_state = "off"
  @last_main_check_in : Time = Time.new(1970, 1, 1, 0, 0, 0)


  @receiver_fiber : Fiber = spawn {}
  @receiver_state = "off"
  @last_receiver_check_in : Time = Time.new(1970, 1, 1, 0, 0, 0)

  @socket_manager_fiber : Fiber = spawn {}
  @socket_manager_states = {} of UUID => String
  @last_socket_manager_check_in : Time = Time.new(1970, 1, 1, 0, 0, 0)


  # Handles output
  @hud_tick_fiber  : Fiber = spawn {}

  @tick_fiber  : Fiber = spawn {}


  # Channel for sending the results of a magic
  @result_channel = Channel(MagicResult?).new
  # Channel that forces a manager to wait until it is called upon to change the socket
  @socket_manage_channels = {} of UUID => Channel(Nil)
  # Channel that stops the fibers execution until the socket has been replaced.
  @socket_wait_channels = {} of UUID => Channel(Nil)

  POOL_MAX = 16
  # Hash of XMSocketTCP UUID to a XMSocketTCP
  @socket_pool : Hash(UUID, XMSocketTCP) = {} of UUID => XMSocketTCP 


  @results = [] of MagicResult
  
  @template : XMMessage = XMMessage.new
  @start_time : Time = Time.now
  @max_timeout = 30
  MAX_RETRIES = 3
  
  CAMERA_WAIT_TIME = Time::Span.new(0, 0, 110)
  

  TCP_PORT = 34567

  getter? is_running = false

  SESSION_REGEX = /,?\h?\"SessionID\"\h\:\h\"0x.{8}\"/

  @current_magic = 0

  def initialize(@magic : Enumerable = (0x03e0..0x08FF), 
          @output : IO = STDOUT,
          @username = "admin", 
          @password = "password",
          hash_password = true,
          @login = true,
          @target_ip = "192.168.1.99",
          @template = XMMessage.new)

    @password = Dahua.digest(@password) if hash_password

    make_pool
  end

  private def make_pool
    @socket_pool = {} of UUID => XMSocketTCP

    POOL_MAX.times do |i|
      success = false

      until success
        begin
          socket = XMSocketTCP.new(@target_ip, TCP_PORT)
          @socket_pool[socket.uuid] = socket
          @socket_pool[socket.uuid].tags[:magic] = 0_u16
          @socket_pool[socket.uuid].tags[:state] = "free"
          @socket_pool[socket.uuid].tags[:timeout] = Time.now
          @socket_pool[socket.uuid].tags[:log] = ""
          @socket_wait_channels[socket.uuid] = Channel(Nil).new
          @socket_manage_channels[socket.uuid] = Channel(Nil).new
          success = true
        rescue e
          if e.is_a? XMError::Exception
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

  private def replace_socket(sock_uuid : UUID)
    old_sock = @socket_pool[sock_uuid]
    new_sock = XMSocketTCP.new(@target_ip, TCP_PORT)
    new_sock.uuid = sock_uuid
    # Replace the socket's uuid, magic, and timeout
    # This will prevent sockets from hanging due to replacement
    @socket_pool[sock_uuid] = new_sock
    @socket_pool[sock_uuid].tags[:magic] = old_sock.tags[:magic]
    @socket_pool[sock_uuid].tags[:timeout] = old_sock.tags[:timeout]
    @socket_pool[sock_uuid].tags[:log] = "FRESHLY REPLACED! #{Time.now}"
    @socket_pool[sock_uuid].tags[:state] = "replaced"
    #close the old socket
    old_sock.close

    new_sock
  end

  private def request_replace_and_wait(uuid : UUID)
    @socket_pool[uuid].tags[:state] = "sending_manage_request"
    # Send the socket uuid that needs replacing
    @socket_manage_channels[uuid].send nil

    @socket_pool[uuid].tags[:state] = "receive_socket_clear"

    # Wait until the channel clears our replacement.
    @socket_wait_channels[uuid].receive

    @socket_pool[uuid].tags[:state] = "received_socket_clear"

  end

  # returns the uuid of a free socket
  private def find_free_socket : (UUID | Nil)
    socket = (@socket_pool.find { |uuid, socket| socket.tags[:state] == "free"})
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
      spawn_main
      spawn_receiver
      spawn_socket_manager
      spawn_hud_tick
      spawn_tick
    end
  end

  def close
    @socket_pool.each {|uuid, socket| socket.close}
    @is_running = false
    @result_channel.close

    @socket_wait_channels.each {|chan| chan[1].close}
    @socket_manage_channels.each {|chan| chan[1].close}
  end

  private def run_magic(socket_uuid : UUID, magic : UInt16)
    @socket_pool[socket_uuid].tags[:magic] = magic

    #for some reason have to for
    @socket_pool[socket_uuid].tags[:state] = "started"
    @socket_pool[socket_uuid].tags[:timeout] = Time.now

    # Make counter variables
    success = false

    result = MagicResult.new
    # make the message from the command class, with the custom magic
    result.message = @template.clone
    result.message.magic = magic

    # Until:
    #   There is success or,
    #   Max number of retries reached or,
    #   Max timeout reached
    until success || (Time.now - @socket_pool[socket_uuid].tags[:timeout].as(Time)).to_i > @max_timeout || !is_running?
      begin
        # Only login if we need to
        if @login
          @socket_pool[socket_uuid].tags[:state] = "logging_in"
          # login, raises an error if login failed
          @socket_pool[socket_uuid].login(@username, @password)

          @socket_pool[socket_uuid].tags[:state] = "logged_in"
        end

        # send message
        @socket_pool[socket_uuid].send_message result.message

        @socket_pool[socket_uuid].tags[:state] = "sent_message"

        @socket_pool[socket_uuid].tags[:state] = "recieving_message"

        # receive reply
        result.reply = @socket_pool[socket_uuid].receive_message
        @socket_pool[socket_uuid].tags[:state] = "received_message"
        success = true
      rescue e : XMError::Exception
        # output the error to the socket's state
        @socket_pool[socket_uuid].tags[:log] = "spawn socket: " + e.inspect + "   " + Time.now.second.to_s
        # Check to see if it's an error we expect
        @socket_pool[socket_uuid].tags[:state] = "error"
        result.error = e.inspect

        # Restart the socket, close, reopen, and replace it
        begin
          @socket_pool[socket_uuid].tags[:state] = "replacing"
          request_replace_and_wait(socket_uuid)
          @socket_pool[socket_uuid].tags[:state] = "replaced"
        rescue err : XMError::Exception
          result.error = err.inspect
          # The camera has crashed, so we need to wait until it comes back up
          # Move the socket time forward CAMERA_WAIT_TIME seconds, to prevent time out due to crash
          # The order of sockets is randomized to ensure that if a command is causing a disconnect, that some new 
          # sockets will still be able to get through and resolve potentially.
          random_wait_time = Time::Span.new(0, 0, rand(5) + 2)
          time = @socket_pool[socket_uuid].tags[:timeout].as(Time) + random_wait_time
          @socket_pool[socket_uuid].tags[:timeout] = time
          @socket_pool[socket_uuid].tags[:log] = "SOCKET ERROR: SLEEPING #{random_wait_time} SECONDS"
          @socket_pool[socket_uuid].tags[:state] = "sleeping"
          sleep random_wait_time
        rescue err
          result.error = err.inspect

          @socket_pool[socket_uuid].tags[:log] = "replace_socket: " + err.inspect
          raise err
        end
      rescue e
        # Mark bad socket, need to figure out how to handle this gracefully
        result.error = e.inspect
        @socket_pool[socket_uuid].tags[:log] = "BAD ERROR!! " + e.inspect
        
        raise e
      end
      # Attempt Fiber.yield once a loop
      Fiber.yield
    end
    #We finished, so let's clean up and send results
    
    @socket_pool[socket_uuid].tags[:log] = "Finished!"

    @socket_pool[socket_uuid].tags[:state] = "finishing"

    # replace the socket 
    request_replace_and_wait(socket_uuid)

    @socket_pool[socket_uuid].tags[:state] = "sending_result"

    # add to results
    @result_channel.send result

    @socket_pool[socket_uuid].tags[:state] = "free"
  end

  # Starts a single socket job
  private def spawn_magic(magic : UInt16)
    socket = nil
    until socket
      main_check_in
      @main_state = "finding socket for #{magic.to_s 16}"
      socket_uuid = find_free_socket
      socket = @socket_pool[socket_uuid]?
      Fiber.yield
    end

    spawn do
      run_magic(socket.as(XMSocketTCP).uuid, magic)
    end
  end

  # check in to show the main fiber is still running / not stuck
  private def main_check_in
    @last_main_check_in = Time.now
  end

  # Starts the fiber that handles the creation of socket jobs
  private def spawn_main
    @main_fiber = spawn do
      @main_state = "on"
      # Go through each magic sequence
      @magic.each do |magic|
        @main_state = "incrementing"

        @current_magic = magic
        # Attempt to find a free socket
        spawn_magic(magic.to_u16)
        Fiber.yield
      end
      
      # Try bad results again, one by one

      # get a list of bad results
      bad_results = @results.select {|result| result.bad?}
      # purge bad results from results to prevent doubling
      @results.reject! {|result| result.bad?}

      @max_timeout = 130

      bad_results.each do |bad_result|
        @main_state = "running magic #{bad_result.message.magic}"

        spawn_magic(bad_result.message.magic)
        sleep 1
      end

      # wait until we are done with all sockets, then mark state done
      until @socket_pool.all? {|uuid, socket| socket.tags[:state] == "free"}
        @main_state =  "waiting_to_finish"
        Fiber.yield
      end

      @main_state = "done"
    end
  end

  private def receiver_check_in
    @last_receiver_check_in = Time.now
  end
  
  private def spawn_receiver
    @receiver_fiber = spawn do
      @receiver_state = "started"
      # if we finished, or are no longer running
      until @main_state == "done" || !is_running?
        receiver_check_in
        @receiver_state = "receiving"

        # Waits until we get a result, or the channel closes.
        result = @result_channel.receive?
        @receiver_state = "received"

        @results << result if result
        Fiber.yield
      end
      @receiver_state = "done"
    end
  end

  private def spawn_socket_manager
    @socket_pool.keys.each do |uuid|
      spawn do
        @socket_manager_states[uuid] = "started"
        until !is_running? || @main_state == "done"
          success = false
          until success || !is_running? || @main_state == "done"
            begin
              @socket_manager_states[uuid] = "waiting_for_signal"
              @socket_manage_channels[uuid].receive
              @socket_manager_states[uuid] = "restarting_socket"
              replace_socket uuid 
              @socket_manager_states[uuid] = "notify"
              @socket_wait_channels[uuid].send nil
              @socket_manager_states[uuid] = "success"
              success = true
            rescue e : Channel::ClosedError
              # do nothing, the channel is closing
            rescue e : XMError::Exception
              @socket_manager_states[uuid] = "error"
            end
            Fiber.yield
          end
          Fiber.yield
        end
        @socket_manager_states[uuid] = "done"
      end
    end
  end

  # Spawns the fiber that runs the HUD tick
  private def spawn_hud_tick
    @hud_tick_fiber = spawn do
      while is_running?
        hud_tick
      end
    end
  end

  # Give HUD output
  private def hud_tick
    clear_screen
    puts "Fuzzing #{@template.message}"
    puts "Time: #{Time.now - @start_time}"
    puts "Current: #{@current_magic-@magic.begin}/#{@magic.size} : #{@current_magic.to_s(16)}"
    puts "Total Completion: #{(((@current_magic-@magic.begin).to_f / @magic.size.to_f)*100).round(3)}%"
    puts "Waiting for magics: "
    # Sort the sockets by their magics, so we know which magics cause the most trouble
    @socket_pool.values.sort{|a, b| a.tags[:magic].as(UInt16) <=> b.tags[:magic].as(UInt16)}.each do |socket|
      if socket
        puts "0x#{socket.tags[:magic].as(UInt16).to_s(16).rjust(4, '0')} : #{socket.tags[:state].to_s.rjust(20, ' ')} : #{@socket_manager_states[socket.uuid]} : #{socket.tags[:log].to_s.rjust(50, ' ')} : #{socket.uuid.to_s.rjust(20, ' ')} : #{(Time.now - socket.tags[:timeout].as(Time)).to_s.rjust(20, ' ')}"
      end
    end
    puts
    puts "Status"
    puts "Main: #{@main_state} : #{@last_main_check_in}"
    puts "Receiver: #{@receiver_state} : #{@last_receiver_check_in}"
    puts 
    puts "Total Results: #{@results.size}" 
    puts "Good: #{@results.count {|r| r.good?}}" 
    puts "Bad: #{@results.count {|r| r.bad?}}" 
    sleep 0.1
  end

  private def spawn_tick
    @tick_fiber = spawn do
      while is_running?
        tick
      end
    end
  end

  # Give HUD output
  private def tick
    # unblock any channels in case they get stuck
    @socket_pool.each do |uuid, socket|
      if @socket_manager_states[uuid] == "waiting_for_signal" && socket.tags[:state] == "receive_socket_clear"
        @socket_wait_channels[uuid].send nil
      end
    end
    Fiber.yield
  end

  def wait_until_done
    until @main_state == "done"
      sleep 1
    end
  end

  def report
    mr = MagicReport.new @output
    mr.make(@start_time, @results)
  end
end


