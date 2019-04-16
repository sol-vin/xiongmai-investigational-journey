require "json"
require "socket"
require "io/hexdump"

require "./dahua_hash"
require "./command"
require "./commands/*"

class MagicFuzzer
  class LoginTimeout < Exception
  end

  class LoginEOF < Exception
  end

  class LoginFailure < Exception
  end

  class LoginConnectionRefused < Exception
  end
  
  class LoginNoRoute < Exception
  end

  
  class CommandTimeout < Exception
  end

  class CommandEOF < Exception
  end

  class CommandLengthZero < Exception
  end

  class CommandConnectionRefused < Exception
  end 

  class CommandNoRoute < Exception
  end

  CLEAR_SCREEN = "\e[H\e[2J"

  private def clear_screen
    puts CLEAR_SCREEN
  end

  # Fiber who's job is to send command packets, keep track of them in @pool, and wait if there are 
  # too many packets that are being waited on.
  @sender_fiber : Fiber = spawn {}
  # Recieves the replies, and categorizes them
  @reciever_fiber  : Fiber = spawn {}
  # Handles output
  @tick_fiber  : Fiber = spawn {}

  POOL_MAX = 16
  @pool = {} of UInt16 => Time

  @successful_results = [] of UInt16
  @results = {} of UInt64 => String
  @results_matches = {} of UInt64 => Array(UInt16)
  @bad_results = {} of UInt16 => String
  
  SENDER_STATES = [:off, :logged_out, :logged_in, :sending, :waiting, :done]
  @sender_state = :off
  @reciever_state =  :off

  @log_messages = [] of String
  @start_time : Time = Time.now
  MAX_TIMEOUT = 10


  getter? is_running = false

  LOGIN_RET_SUCCESS = 100
  LOGIN_RET_UNKNOWN = 106
  LOGIN_RET_FAILURE = 205
  getter? logged_in = false

  SESSION_REGEX = /,?\h?\"SessionID\"\h\:\h\"0x.{8}\"/

  @error_log = {} of Time => String
  @current_magic = 0

  def initialize(@command_class : Command.class, 
          @magic : Enumerable = (0x0000..0x08FF), 
          @output : IO = STDOUT,
          @username = "admin", 
          @password = "", 
          hash_password = true, 
          @login = true,
          @target_ip = "192.168.11.109")
    @password = Dahua.digest(@password) if hash_password
    @socket = TCPSocket.new
  end

  def run
    unless is_running?
      @is_running = true
      @start_time = Time.now
      spawn_sender
      spawn_reciever
      spawn_tick
    end
  end

  def open
    @socket = TCPSocket.new(@target_ip, 34567)
    @socket.read_timeout = 5
  end

  def close
    if is_running?
      @is_running = false
      @socket.close
      logout
    end
  end

  def send_login
    @socket.close
    open
    login_command = Command::Login.new(username: @username, password: @password)
    @socket << login_command.make

    sleep 1
  end

  def logout
    @logged_in = false
  end

  private def recieve_message
    type = @socket.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    session_id = @socket.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    unknown = @socket.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    unknown2 = @socket.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
    magic = @socket.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
    json_size = @socket.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

    reply = ""
    unless json_size == 0
      reply = @socket.read_string(json_size-1)
    end

    @socket.read_byte #bleed this byte

    {type: type, session_id: session_id, unknown: unknown, magic: magic, json_size: json_size, json: reply}
  end

  private def add_to_pool(magic : UInt16)
    if @pool.size < POOL_MAX
      @sender_state = :sending
      @pool[magic] = Time.now
      send_command magic
    else
      until @pool.size < POOL_MAX
        clean_pool
      end
    end
  end

  private def clean_pool
    @sender_state = :cleaning
    @pool.keys.each {|magic| send_command magic}
    until @pool.size == 0 || !logged_in?
      Fiber.yield

      @pool.reject! do |magic, time|

        if (Time.now-time).to_i >= MAX_TIMEOUT && @successful_results.index(magic)
          @bad_results[magic] = "Timeout Reached"
        end

        (Time.now-time).to_i >= MAX_TIMEOUT
      end
    end
  end

  private def send_command(magic : UInt16)
    command = @command_class.new(magic: magic, session_id: magic.to_u32)
    @socket << command.make
  end



  # Handles the pool, adding new magics to the pool, and waiting when it gets too full.
  # Handles login as well, ensures the device is logged in if a disconnect occurs
  private def spawn_sender
    @sender_fiber = spawn do
      @magic.each do |magic|
        @current_magic = magic
        while is_running?


          begin
            @sender_state = :logging_in
            until logged_in?
              send_login
            end
            @sender_state = :logged_in

            add_to_pool(magic.to_u16) unless @pool[magic]?
            clean_pool


            break
          rescue IO::EOFError
            # Ignore and retry
            @sender_state = :eof_error
          rescue IO::Timeout
            # Ignore and retry
            @sender_state = :timeout_error
          rescue e
            if e.to_s.includes? "Connection refused"
              # Ignore and retry
              @sender_state = :connection_error
              logout
            elsif e.to_s.includes? "No route to host"
              # Ignore and retry
              @sender_state = :no_route_error
              logout           
            elsif e.to_s.includes? "Broken pipe"
              @sender_state = :broken_pipe_error
              logout
            elsif e.to_s.includes? "Closed stream"
              @sender_state = :closed_error
              logout
            else
              @error_log[Time.now] = "SENDER_FIBER : #{e.to_s}"
              raise e
            end
          end
        end
      end
      clean_pool
      @sender_state = :done
    end
  end

  private def spawn_reciever
    @reciever_fiber = spawn do
      while is_running?
        begin
          @reciever_state = :recieving

          reply = recieve_message
          if reply[:magic] == 0x03E9
            parsed = JSON.parse(reply[:json])
            @logged_in = (parsed["Ret"] == LOGIN_RET_SUCCESS || parsed["Ret"] == LOGIN_RET_UNKNOWN)
          else
            @reciever_state = :recieved_message
            if reply[:json] =~ SESSION_REGEX
              reply_json = reply[:json].gsub(reply[:json][SESSION_REGEX], "")
            else
              reply_json = reply[:json]
            end
            unless @results.keys.any? {|r| r == reply_json.hash}
              # Add it to the results
              @results[reply_json.hash] = reply[:json]
              # Add a new array for magic sequence results
              @results_matches[reply_json.hash] = [] of UInt16

            end

            # Add magic sequence to the result matches.
            @results_matches[reply_json.hash] << reply[:session_id].to_u16
            @successful_results << reply[:session_id].to_u16
            #remove magic from pool, remember, we use sessionID to identify the magic coming back to us
            @pool.delete reply[:session_id].to_u16
          end
        rescue IO::EOFError
          @reciever_state = :eof_error
        rescue IO::Timeout
          @reciever_state = :timeout_error
        rescue e
          if e.to_s.includes? "Connection refused"
            @reciever_state = :connection_error
          elsif e.to_s.includes? "No route to host"
            @reciever_state = :no_route_error
          elsif e.to_s.includes? "Broken pipe"
            @reciever_state = :broken_pipe_error
          elsif e.to_s.includes? "Transport endpoint is not connected"
            @reciever_state = :endpoint_error
          elsif e.to_s.includes? "Closed stream"
            @reciever_state = :closed_error
          else
            @error_log[Time.now] = "RECIEVER_FIBER : #{e.to_s}"
            raise e
          end
        ensure
          Fiber.yield
        end
      end
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
    puts "Time: #{Time.now - @start_time}"
    puts "Current: #{@current_magic-@magic.begin}/#{@magic.size}"
    puts "Total Completion: #{(((@current_magic-@magic.begin).to_f / @magic.size.to_f)*100).round(3)}%"
    puts "Waiting for magics: "
    @pool.each do |magic, time|
      puts "0x#{magic.to_s(16)}: #{Time.now-time}"
    end
    puts
    puts "Status"
    puts "Logged In: #{@logged_in}"
    puts "Sender: #{@sender_state}"
    puts "Reciever: #{@reciever_state}"

    puts "Total Unique Replies: #{@results.keys.size}"
    puts "Total Replies: #{@successful_results.size}"
    puts "Total Bad Results: #{@bad_results.keys.size}"
    puts "Errors: #{@error_log}"
    puts 
    @results.values.each {|v| puts v}
    sleep 0.3
  end

  def wait_until_done
    until @pool.size == 0 && @sender_state == :done
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



