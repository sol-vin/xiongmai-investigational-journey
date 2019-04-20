require "socket"
require "uuid"

require "./magic_error"

class MagicSocket < TCPSocket

  property uuid : UUID
  property magic : UInt16 = 0_u16
  property timeout : Time = Time.now
  property state : String = "new"
  property log : String = "Nothing yet!"

  def initialize(host, port)
    @uuid = UUID.random
    begin
      super host, port
      self.read_timeout = 5

    rescue e
      if e.to_s.includes? "Connection refused"
        raise MagicError::SocketConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise MagicError::SocketNoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise MagicError::SocketBrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise MagicError::SocketConnectionReset.new 
      else
        raise e
      end
    end

  end

  def login(username, password)
    begin
      login_command = Command::Login.new(username: username, password: password)
      self << login_command.make
      reply = recieve_message
      begin
        unless [Command::Login::SUCCESS, Command::Login::UNKNOWN].includes? JSON.parse(reply.message)["Ret"]
          raise MagicError::LoginFailure.new
        end
      rescue e
        # Speicically filter out json "unexpected char/token" error
        raise e unless e.to_s =~ /^[Uu]nexpected/
      end
      Fiber.yield
    rescue e : IO::EOFError
      raise MagicError::LoginEOF.new
    rescue e : IO::Timeout
      raise MagicError::LoginTimeout.new
    rescue e
      if e.to_s.includes? "Connection refused"
        raise MagicError::LoginConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise MagicError::LoginNoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise MagicError::LoginBrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise MagicError::LoginConnectionReset.new 
      else
        raise e
      end
    end
  end

  def recieve_message : XMMessage
    begin
      m = XMMessage.new
      m.type = self.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      m.session_id = self.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      m.unknown1 = self.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      m.unknown2 = self.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
      m.magic = self.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
      m.size = self.read_bytes(UInt32, IO::ByteFormat::LittleEndian)

      unless m.size == 0
        m.message = self.read_string(m.size-1)
      end

      self.read_byte #bleed this byte

      m
    rescue e : IO::EOFError
      raise MagicError::RecieveEOF.new
    rescue e : IO::Timeout
      raise MagicError::RecieveTimeout.new
    rescue e
      if e.to_s.includes? "Connection refused"
        raise MagicError::RecieveConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise MagicError::RecieveNoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise MagicError::RecieveBrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise MagicError::RecieveConnectionReset.new 
      else
        raise e
      end
    end
  end

  def send_message(xmm : XMMessage)
    begin
      self << xmm.make
    rescue e : IO::EOFError
      raise MagicError::SendEOF.new
    rescue e : IO::Timeout
      raise MagicError::SendTimeout.new
    rescue e
      if e.to_s.includes? "Connection refused"
        raise MagicError::SendConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise MagicError::SendNoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise MagicError::SendBrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise MagicError::SendConnectionReset.new 
      else
        raise e
      end
    end
  end
end