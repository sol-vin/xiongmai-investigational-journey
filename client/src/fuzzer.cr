require "json"
require "socket"
require "io/hexdump"

require "./dahua_hash"
require "./command"
require "./commands/*"

module Fuzzer
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

  def self.run(command : Command, magic1 : Enumerable = (0..0xFF), magic2 : Enumerable  = (0x3..0x8), output = STDOUT, username = "admin", password = "", hash_password = true, login = true)
    start_time = Time.now

    # Results of the fuzz. Saves the reply's hash to it's text
    # Key: Reply hash. 
    # Value: Reply text.
    results = {} of UInt64 => String

    # Which magic sequences went to what reply.
    # Key: Reply hash. 
    # Value: Array of magic sequences.
    results_matches = {} of UInt64 => Array(Int32)

    # Which magic sequences caused a raise Exception.
    # Key: Magic sequence
    # Value: Reason for failure
    bad_results = {} of Int32 => String

    # Only parse the command via JSON if it's empty.
    unless command.json.empty?
      parsed = JSON.parse command.json
      if parsed["Name"]?
        puts "Starting command fuzz: Name - #{parsed["Name"]}"
        puts
      end
    end

    # Go through each magic sequence
    magic2.each do |magic2|
      puts "Magic2: 0x#{magic2.to_s(16).rjust(2, '0')}"
      magic1.each do |magic1|
        # Output marker for progress
        if magic1 % 0x10 == 0
          print "."
        elsif magic1 == 0xFF
          print "!"
          puts puts
        end

        # Build the magic sequence
        magic = (magic2 << 8) + magic1

        retry_count = 0
        # Did the command succeed in getting a reply?
        success = false

        while !success && retry_count < 5
          begin
            # Make our own command from a blank one, add the magic sequence, and json from the original.
            command = Command.new(magic1.to_u8, magic2.to_u8, command.json)
            # Send the command and attempt to get a reply. This will throw errors depending on the problem.
            reply = run_command(command, username: username, password: password, login: login)

            # Check if we have a unique result
            unless results.keys.any? {|r| r == reply.hash}
              # Add it to the results
              results[reply.hash] = reply
              # Add a new array for magic sequence results
              results_matches[reply.hash] = [] of Int32
            end
            # Add magic sequence to the result matches.
            results_matches[reply.hash] << magic
            success = true
          rescue CommandEOF
            bad_results[magic] = "Command EOF"
            retry_count += 1
            sleep 1
          rescue CommandTimeout
            bad_results[magic] = "Command Timeout"
            retry_count += 1
            sleep 1
          rescue CommandLengthZero
            bad_results[magic] = "Command Length Zero"
            retry_count += 1
            sleep 1
          rescue CommandConnectionRefused
            bad_results[magic] = "Command Connection Refused"
            retry_count += 1
            sleep 5
          rescue CommandNoRoute
            bad_results[magic] = "Command No Route"
            retry_count += 1
            sleep 5
          rescue LoginEOF
            bad_results[magic] = "Login EOF"
            retry_count += 1
            sleep 5
          rescue LoginTimeout
            bad_results[magic] = "Login Timeout"
            retry_count += 1
            sleep 1
          rescue LoginFailure
            bad_results[magic] = "Login Failure"
            retry_count += 1
            sleep 1
          rescue LoginConnectionRefused
            bad_results[magic] = "Login Connection Refused"
            retry_count += 1
            sleep 5
          rescue LoginNoRoute
            bad_results[magic] = "Login No Route"
            retry_count += 1
            sleep 5
          end
        end
        sleep 0.1
      end
    end

    output.puts "Command results: Started at #{start_time}"
    output.puts "Total time: #{Time.now - start_time}"

    results.each do |k, v|
      if v.valid_encoding?
        output.puts v.dump
      else
        output.puts "BINARY FILE #{v[0..20].dump}"
      end
      output.puts "    Bytes: #{results_matches[k].map {|k| "0x#{k.to_s(16).rjust(4, '0')}"}}"
    end
    
    output.puts
    output.puts "Bad Results"
    bad_results.each {|k, v| output.puts "#{k.to_s(16).rjust(4, '0')} : #{v}" }
  end

  def self.run_command(command : Command, username = "admin", password = "", hash_password = true, login = true) : String

    socket = TCPSocket.new

    begin
      socket = TCPSocket.new("192.168.11.109", 34567)
      # Very important, camera replies usually within 0.1-0.2 seconds, need to adjust this accordingly.
      socket.read_timeout = 1
      # Send the data via socket
      
      #login_reply = nil

      if login
        login_command = Command::Login.new(username, password, hash_password: hash_password)
        socket << login_command.make

        # Start consuming the header data
        type = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
        sessionid = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
        unknown = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
        weird = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
        login_json_size = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)

        # Get the rest of the reply data 
        login_reply = socket.read_string(login_json_size).chomp("\x00")
      end

      if login_reply && JSON.parse(login_reply)["Ret"] == 100
        begin
          socket << command.make
          type = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
          sessionid = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
          unknown = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
          weird = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
          command_json_size = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
          if command_json_size == 0
            raise CommandLengthZero.new
          end
          command_reply = socket.read_string(command_json_size-1)
          socket.read_byte #bleed this byte
          socket.close
          return command_reply
        rescue e : IO::EOFError
          raise CommandEOF.new
        rescue e : IO::Timeout
          raise CommandTimeout.new
        rescue e
          if e.to_s.includes? "Connection refused"
            raise CommandConnectionRefused.new
          elsif e.to_s.includes? "No route to host"
            raise CommandNoRoute.new
          else
            raise e
          end
        ensure
          socket.close
        end
      else
        raise LoginFailure.new
      end
    rescue e : IO::EOFError
      raise LoginEOF.new
    rescue e : IO::Timeout
      raise LoginTimeout.new
    rescue e
      if e.to_s.includes? "Connection refused"
        raise LoginConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise LoginNoRoute.new
      else
        raise e
      end
    ensure
      socket.close
    end
  end
end



