require "socket"
require "uuid"

require "./errors"

class XMSocket < TCPSocket

  property uuid : UUID
  property magic : UInt16 = 0_u16
  property timeout : Time = Time.now
  property state : String = "new"
  property log : String = "Nothing yet!"

  def initialize(host, port)
    @uuid = UUID.random
    begin
      super host, port
      self.read_timeout = 1

    rescue e
      if e.to_s.includes? "Connection refused"
        raise XMError::SocketConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise XMError::SocketNoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise XMError::SocketBrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise XMError::SocketConnectionReset.new 
      else
        raise e
      end
    end

  end

  def login(username, password)
    begin
      login_command = Command::Login.new(username: username, password: password)
      self << login_command.to_s
      reply = receive_message
      begin
        unless [Command::Login::SUCCESS, Command::Login::UNKNOWN].includes? JSON.parse(reply.message)["Ret"]
          raise XMError::LoginFailure.new
        end
      rescue e
        # Speicically filter out json "unexpected char/token" error
        raise e unless e.to_s =~ /^[Uu]nexpected/
      end
      Fiber.yield
    rescue e : IO::EOFError
      raise XMError::LoginEOF.new
    rescue e : IO::Timeout
      raise XMError::LoginTimeout.new
    rescue e
      if e.to_s.includes? "Connection refused"
        raise XMError::LoginConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise XMError::LoginNoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise XMError::LoginBrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise XMError::LoginConnectionReset.new 
      elsif e.to_s.includes? "Bad file descriptor"
        raise XMError::LoginBadFileDescriptor.new 
      else
        raise e
      end
    end
  end

  def receive_message : XMMessage
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
      raise XMError::ReceiveEOF.new
    rescue e : IO::Timeout
      raise XMError::ReceiveTimeout.new
    rescue e
      if e.to_s.includes? "Connection refused"
        raise XMError::ReceiveConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise XMError::ReceiveNoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise XMError::ReceiveBrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise XMError::ReceiveConnectionReset.new 
      elsif e.to_s.includes? "Bad file descriptor"
        raise XMError::ReceiveBadFileDescriptor.new 
      else
        raise e
      end
    end
  end

  def send_message(xmm : XMMessage)
    begin
      self << xmm.to_s
    rescue e : IO::EOFError
      raise XMError::SendEOF.new
    rescue e : IO::Timeout
      raise XMError::SendTimeout.new
    rescue e
      if e.to_s.includes? "Connection refused"
        raise XMError::SendConnectionRefused.new
      elsif e.to_s.includes? "No route to host"
        raise XMError::SendNoRoute.new
      elsif e.to_s.includes? "Broken pipe"
        raise XMError::SendBrokenPipe.new
      elsif e.to_s.includes? "Connection reset"
        raise XMError::SendConnectionReset.new 
      elsif e.to_s.includes? "Bad file descriptor"
        raise XMError::SendBadFileDescriptor.new 
      else
        raise e
      end
    end
  end
end