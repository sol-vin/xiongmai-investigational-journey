# Class that contains the basic process for making a message to/from the camera
class XMMessage
  property type : UInt8
  property version : UInt8
  property reserved1 : UInt8
  property reserved2 : UInt8
  property session_id : UInt32
  property sequence : UInt32
  property total_packets : UInt8
  property current_packet : UInt8
  property command : UInt16
  property size : UInt32
  property message : String

  property? use_custom_size : Bool = false

  def self.from_s(string) : XMMessage
    io = IO::Memory.new string
    m = XMMessage.new
    m.type = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    m.version = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    m.reserved1 = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    m.reserved2 = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    m.session_id = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.sequence = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.total_packets = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    m.current_packet = io.read_bytes(UInt8, IO::ByteFormat::LittleEndian)
    m.command = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
    m.size = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.message = string[20..] # Love you crystal infinite ranges <3
    if m.size != m.message.size
      m.use_custom_size = true
    end
    m
  end

  def initialize(@type = 0xff_u8, @version = 0x01_u8, @reserved1 = 0x00_u8, @reserved2 = 0x00_u8, @session_id = 0_u32, @sequence = 0_u32, @total_packets = 0_u8, @current_packet = 0_u8, @command = 0_u16, @size = 0_u32, @message = "")
  end

  def command1 : UInt8
    (command & 0xFF).to_u8
  end

  def command2 : UInt8
    (command >> 8).to_u8
  end

  def header
    header_io = IO::Memory.new
    header_io.write_bytes(type, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(version, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(reserved1, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(reserved2, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(session_id, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(sequence, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(total_packets, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(current_packet, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(command, IO::ByteFormat::LittleEndian)
    if use_custom_size?
      header_io.write_bytes(size, IO::ByteFormat::LittleEndian)
    else
      header_io.write_bytes(message.size, IO::ByteFormat::LittleEndian)
    end

    header_io.to_s
  end

  def to_s : String
    (header + self.message)
  end

  def clone : XMMessage
    x = XMMessage.new
    x.type = type
    x.version = version
    x.reserved1 = reserved1
    x.reserved2 = reserved2
    x.session_id = session_id
    x.sequence = sequence
    x.total_packets = total_packets
    x.current_packet = current_packet
    x.command = command
    x.size = size
    x.message = message

    x.use_custom_size = use_custom_size?
    x
  end
end