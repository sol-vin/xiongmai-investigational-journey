require "json"

require "../xmmessage"
require "../dahua_hash"
require "../commands/*"

require "./magic_error"
require "./magic_socket"

class MagicFuzzer(Command)
  CLEAR_SCREEN = "\e[H\e[2J"

  private def clear_screen
    puts CLEAR_SCREEN
  end

  @factory_fiber : Fiber = spawn {}

  # Handles output
  @tick_fiber  : Fiber = spawn {}

  POOL_MAX = 16
  # List of what ports are bound to what magics
  @socket_pool = {} of MagicSocket => UInt16
  @socket_states = {} of MagicSocket => String
  @socket_times = {} of MagicSocket => Time

  @successful_replies = 0
  @results = {} of UInt64 => String
  @results_matches = {} of UInt64 => Array(UInt16)
  @bad_results = {} of UInt16 => String
  
  @factory_state = :off

  @log_messages = [] of String
  @start_time : Time = Time.now
  MAX_TIMEOUT = 120

  @last_factory_check_in : Time = Time.now

  TCP_PORT = 34567

  getter? is_running = false

  SESSION_REGEX = /,?\h?\"SessionID\"\h\:\h\"0x.{8}\"/

  @last_error = ""
  @error_log = {} of Time => String
  @current_magic = 0

  def initialize(@magic : Enumerable = (0x0000..0x08FF), 
          @output : IO = STDOUT,
          @username = "admin", 
          @password = "",
          hash_password = true,
          @login = true,
          @target_ip = "192.168.11.109")

    @password = Dahua.digest(@password) if hash_password

    #TODO: Make this work even if we cant connect to camera yet.
    make_pool
  end

  private def make_pool
    @socket_pool = {} of MagicSocket => UInt16
    @socket_states = {} of MagicSocket => String
    @socket_times = {} of MagicSocket => Time

    POOL_MAX.times do |i|
      socket = MagicSocket.new(@target_ip, TCP_PORT)
      @socket_pool[socket] = 0
      @socket_states[socket] = "unused"
      @socket_times[socket] = Time.now
    end
  end

  private def replace_socket(old_sock, new_sock)
    @socket_pool.delete old_sock
    @socket_states.delete old_sock

    @socket_pool[new_sock] = 0
    @socket_states[new_sock] = "replaced"
    @socket_times[new_sock] = @socket_times[old_sock]

    @socket_times.delete old_sock
    new_sock
  end

  private def find_free_socket
    sockets = (@socket_states.find { |socket, state| state == "unused"})
    if sockets
      sockets[0]
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
    @socket_pool.each {|s, _| s.close}
  end

  private def factory_check_in
    @last_factory_check_in = Time.now
  end

  private def spawn_factory
    @factory_fiber = spawn do
      @factory_state = :on
      # Go through each magic sequence
      @magic.each do |magic|
        @factory_state = :incrementing

        @current_magic = magic
        # Attempt to find a free socket
        socket = nil
        until socket
          factory_check_in
          @factory_state = :finding
          socket = find_free_socket
          Fiber.yield
        end
        # If we did find a socket
        if socket
          @factory_state = :creating

          # Bind socket to magic
          @socket_pool[socket] = magic.to_u16
          spawn do
            found_socket = socket.as(MagicSocket)
            @socket_states[found_socket] = "started"
            @socket_times[found_socket] = Time.now

            # Make counter variables
            success = false

            # Until:
            #   There is success or,
            #   Max number of retries reached or,
            #   Max timeout reached
            until success || (Time.now- @socket_times[found_socket] ).to_i > MAX_TIMEOUT
              begin
                if @login
                  @socket_states[found_socket] = "logging_in"
                  # login, raises an error if login failed
                  found_socket.login(@username, @password)

                  @socket_states[found_socket] = "logged_in"
                end

                # make the message from the command class, with the custom magic
                c = Command.new(magic: magic.to_u16)
                # send
                found_socket.send_message c

                @socket_states[found_socket] = "sent_message"

                Fiber.yield

                @socket_states[found_socket] = "recieving_message"

                # recieve reply
                m = found_socket.recieve_message
                @socket_states[found_socket] = "recieved_message"


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
              rescue e
                @socket_states[found_socket] = e.inspect
                # Check to see if it's an error we expect
                if MagicError::ALL_ERRORS.any? {|err| err == e.class}
                  # Restart the socket, close, reopen, and replace it
                  begin
                    found_socket = replace_socket(found_socket, MagicSocket.new(@target_ip, TCP_PORT))
                    @socket_pool[found_socket] = magic.to_u16
                  rescue e
                    @socket_states[found_socket] = e.inspect
                  end
                else
                  # Mark bad socket, need to figure out how to handle this gracefully
                  @socket_states[found_socket] = "BAD ERROR!! " + e.inspect
                  raise e
                end
                sleep 1
              end
              # Attempt Fiber.yield once a loop
              Fiber.yield
            end
            @bad_results[magic.to_u16] = e.inspect unless success
            @socket_states[found_socket] = "unused"
          end
        end
        Fiber.yield
      end
      @factory_state = :done
    end
  end

  private def spawn_tick
    @tick_fiber = spawn do
      while is_running?
        tick
      end
    end
  end

  def tick
    clear_screen
    puts "Fuzzing #{Command}"
    puts "Time: #{Time.now - @start_time}"
    puts "Current: #{@current_magic-@magic.begin}/#{@magic.size} : #{@current_magic.to_s(16)}"
    puts "Total Completion: #{(((@current_magic-@magic.begin).to_f / @magic.size.to_f)*100).round(3)}%"
    puts "Waiting for magics: "
    @socket_pool.each do |socket, magic|
      if @socket_states[socket] != :unused
        puts "0x#{magic.to_s(16).rjust(4, '0')} : #{@socket_states[socket].rjust(80, ' ')} : #{socket.hash.to_s.rjust(20, ' ')} : #{(Time.now-@socket_times[socket]).to_s.rjust(20, ' ')}"
      end
    end
    puts
    puts "Status"
    puts "Factory: #{@factory_state}"
    puts "Last Check In: #{@last_factory_check_in}"

    puts "Total Successes: #{@successful_replies}"
    puts "Total Unique Replies: #{@results.keys.size}"
    puts "Total Bad Results: #{@bad_results.keys.size}"
    puts "Error: #{@last_error}"
    puts "Errors: #{@error_log}"
    puts 
    #@results.values.each {|v| puts v}
    sleep 0.2
  end

  def wait_until_done
    until @socket_states.all? {|socket, state| state == "unused"} && @factory_state == :done
      sleep 1
    end
  end

  def report
    @output.puts "Command results: Started at #{@start_time}"
    @output.puts "Total time: #{Time.now - @start_time}"

    @results.each do |k, v|
      if v.valid_encoding?
        @output.puts v.dump
      else
        @output.puts "BINARY FILE #{v[0..20].dump}"
      end
      @output.puts "    Bytes: #{@results_matches[k].map {|k| "0x#{k.to_s(16).rjust(4, '0')}"}}"
    end
    
    @output.puts
    @output.puts "Bad Results"
    @bad_results.each {|k, v| @output.puts "#{k.to_s(16).rjust(4, '0')} : #{v}" }
    @output.flush
  end
end


