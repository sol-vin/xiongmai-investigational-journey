# Class that contains the basic process for making a message to/from the camera
class XMMessage
  property type : UInt32
  property session_id : UInt32
  property unknown1 : UInt32
  property unknown2 : UInt16
  property magic : UInt16
  property size : UInt32
  property message : String

  property? use_custom_size : Bool = false

  #TODO: Allow for spoofing of size, for example changing size to say that its 32 bytes, when its 0 or something
  def self.from_s(string) : XMMessage
    io = IO::Memory.new string
    m = XMMessage.new
    m.type = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.session_id = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.unknown1 = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.unknown2 = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
    m.magic = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
    m.size = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.message = string[20..]
    if m.size != m.message.size
      m.use_custom_size = true
    end
    m
  end

  def initialize(@type = 0x000001ff_u32, @session_id = 0_u32, @unknown1 = 0_u32, @unknown2 = 0_u16, @magic = 0_u16, @size = 0_u32, @message = "")
  end

  def magic1 : UInt8
    (magic & 0xFF).to_u8
  end

  def magic2 : UInt8
    (magic >> 8).to_u8
  end

  def header
    header_io = IO::Memory.new
    header_io.write_bytes(type, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(session_id, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(unknown1, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(unknown2, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(magic, IO::ByteFormat::LittleEndian)
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
    x.session_id = session_id
    x.unknown1 = unknown1
    x.unknown2 = unknown2
    x.magic = magic
    x.size = size
    x.message = message

    x.use_custom_size = use_custom_size?
    x
  end
end