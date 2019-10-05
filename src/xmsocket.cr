require "socket"
require "uuid"

require "./errors"

module XMSocket
  TCP_PORT = 34567
  UDP_PORT = 34569
  #alias ALL =  (String | UInt16 | Time | Float32)
  #property tags : Hash(Symbol, ALL) = {} of Symbol => ALL

  getter target = Socket::IPAddress.new("0.0.0.0", 0)

  def set_target(socket_ip)
    @target = socket_ip
  end

  # Target a camera.
  def set_target(ip : String, port = 0)
    @target = Socket::IPAddress.new(ip, port)
  end
  
  # Have we found at least one target yet?
  def has_target?
    @target.port != 0
  end

  def login(username = "admin", password = "password")
    begin
      login_command = Command::Login::Request.new(username: username, password: password)
      self.send_raw_message login_command.to_s
      reply = receive_message
      begin
        unless [Command::Login::Request::SUCCESS, Command::Login::Request::UNKNOWN].includes? JSON.parse(reply.message)["Ret"]
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
      m.type = self.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
      m.version = self.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
      m.reserved1 = self.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
      m.reserved2 = self.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
      m.session_id = self.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      m.sequence = self.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
      m.total_packets = self.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
      m.current_packet = self.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
      m.command = self.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
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
      self.send_raw_message xmm.to_s
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

class XMSocketTCP < TCPSocket
  
  include XMSocket

  def initialize(host, port)
    begin
      super host, port
      set_target(host, port)
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

  def send_raw_message(message)
    self << message.to_s
  end
end

class XMSocketUDP < UDPSocket
  
  include XMSocket

  def initialize(host, port)
    begin
      super(Family::INET)
      set_target(host, port)
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

  def send_raw_message(message)
    self.send(message.to_s, target)
  end
end