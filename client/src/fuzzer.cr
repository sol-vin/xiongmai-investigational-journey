require "json"
require "socket"
require "io/hexdump"

require "./dahua_hash"

module Fuzzer
  class LoginTimeout < Exception
  end

  class LoginEOF < Exception
  end

  class LoginFailure < Exception
  end

  class LoginConnectionRefused < Exception
  end

  
  class CommandTimeout < Exception
  end

  class CommandEOF < Exception
  end

  class CommandLengthZero < Exception
  end

  class CommandConnectionRefused < Exception
  end  

  def self.make_login_header(json)
    "\xff\x01\x00\x00\x00\x00\x00\x00\x18\x00\x00\x00\x00\x00\xe8\x03#{String.new(Bytes[json.size])}\x00\x00\x00"
  end

  def self.make_special_header(json, weird_byte1, weird_byte2 = 0x3)
    "\xff\x01\x00\x00\x17\x11\x11\x11\x00\x00\x00\x00\x00\x00" +
    "#{String.new(Bytes[weird_byte1])}#{String.new(Bytes[weird_byte2])}#{String.new(Bytes[json.size])}\x00\x00\x00"
  end

  def self.run_auth_fuzz(command : String, password, weird_byte2 = 3, output = STDOUT)
    results = {} of UInt64 => String
    results_matches = {} of UInt64 => Array(Int32)
    bad_results = {} of Int32 => String

    0x100.times do |weird_byte1|
      if weird_byte1 % 0x10 == 0
        print "."
      elsif weird_byte1 == 0xFF
        puts puts
      end
      begin
        reply = run_auth_command(command, password, weird_byte1, weird_byte2)
        unless results.keys.any? {|r| r == reply.hash}
          results[reply.hash] = reply
          results_matches[reply.hash] = [] of Int32
        end
        results_matches[reply.hash] << weird_byte1
      rescue CommandEOF
        bad_results[weird_byte1] = "Command EOF"
      rescue CommandTimeout
        bad_results[weird_byte1] = "Command Timeout"
      rescue CommandLengthZero
        bad_results[weird_byte1] = "Command Length Zero"
      rescue CommandConnectionRefused
        bad_results[weird_byte1] = "Command Connection Refused"
      rescue LoginEOF
        bad_results[weird_byte1] = "Login EOF"
        sleep 1
      rescue LoginTimeout
        bad_results[weird_byte1] = "Login Timeout"
      rescue LoginFailure
        bad_results[weird_byte1] = "Login Failure"
      rescue LoginConnectionRefused
        bad_results[weird_byte1] = "Login Connection Refused"
      end
      sleep 0.1
    end

    results.each do |k, v|
      output.puts v.dump
      output.puts "    Bytes: #{results_matches[k].map {|k| "0x#{k.to_s(16).rjust(2, '0')}"}}"
    end
    
    output.puts
    output.puts "Bad Results"
    bad_results.each {|k, v| output.puts "#{k.to_s(16).rjust(2, '0')} : #{v}" }
  end

  def self.run_no_auth_fuzz(command, weird_byte2 = 3)
    results = {} of UInt64 => String
    results_matches = {} of UInt64 => Array(Int32)
    bad_results = {} of Int32 => String

    0x100.times do |weird_byte1|
      begin
        reply = run_no_auth_command(command, weird_byte1, weird_byte2)
        unless results.keys.any? {|r| r == reply.hash}
          results[reply.hash] = reply
          results_matches[reply.hash] = [] of Int32
        end
        results_matches[reply.hash] << weird_byte1
      rescue CommandEOF
        bad_results[weird_byte1] = "Command EOF"
      rescue CommandTimeout
        bad_results[weird_byte1] = "Command Timeout"
      rescue CommandLengthZero
        bad_results[weird_byte1] = "Command Length Zero"
      rescue CommandConnectionRefused
        bad_results[weird_byte1] = "Command Connection Refused"
      end
      sleep 0.1
    end

    results.each do |k, v|
      pp v
      puts "    Bytes: #{results_matches[k].map {|k| "0x#{k.to_s(16).rjust(2, '0')}"}}"
    end
    
    puts
    puts "Bad Results"
    bad_results.each {|k, v| puts "#{k.to_s(16).rjust(2, '0')} : #{v}" }
  end


  def self.run_no_auth_command(command, weird_byte1, weird_byte2)
    socket = TCPSocket.new
    begin
      socket = TCPSocket.new("192.168.11.109", 34567)
      socket.read_timeout = 10
      socket << (make_special_header(command, weird_byte, weird_byte2) + command)
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
      else
        raise e
      end
    ensure
      socket.close
    end
    raise Exception.new "SHOULDNT GET HERE!"
  end

  def self.run_auth_command(command : String, password, weird_byte1, weird_byte2) : String
    login = JSON.build do |json|
      json.object do
        json.field "EncryptType", "MD5"
        json.field "LoginType", "DVRIP-Xm030"
        json.field "UserName", "admin"
        json.field "PassWord", Dahua.digest(password)
      end
    end

    socket = TCPSocket.new

    begin
      socket = TCPSocket.new("192.168.11.109", 34567)
      socket.read_timeout = 1
      socket << (make_login_header(login) + login)
      type = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
      sessionid = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
      unknown = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
      weird = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
      login_json_size = socket.read_bytes(Int32, IO::ByteFormat::LittleEndian)
      login_reply = socket.read_string(login_json_size).chomp("\x00")
      if login_reply

        login_reply_parsed = JSON.parse login_reply

        if login_reply_parsed["Ret"] == 100
          begin
            socket << (make_special_header(command, weird_byte1, weird_byte2) + command)
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
            else
              raise e
            end
          ensure
            socket.close
          end
        else
          raise LoginFailure.new
        end
      end
    rescue e : IO::EOFError
      raise LoginEOF.new
    rescue e : IO::Timeout
      raise LoginTimeout.new
    rescue e
      if e.to_s.includes? "Connection refused"
        raise LoginConnectionRefused.new
      else
        raise e
      end
    ensure
      socket.close
    end
    raise Exception.new "SHOULDNT GET HERE!"
  end
end



