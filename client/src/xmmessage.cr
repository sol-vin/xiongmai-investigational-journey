# Struct that contains the basic process for making a 
class XMMessage
  property type : UInt32
  property session_id : UInt32
  property unknown1 : UInt32
  property unknown2 : UInt16
  property magic : UInt16
  property size : UInt32
  property message : String

  #TODO: Allow for spoofing of size, for example changing size to say that its 32 bytes, when its 0 or something
  def self.from_s(string)
    io = IO::Memory.new string
    m = XMMessage.new
    m.type = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.session_id = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.unknown1 = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.unknown2 = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
    m.magic = io.read_bytes(UInt16, IO::ByteFormat::LittleEndian)
    m.size = io.read_bytes(UInt32, IO::ByteFormat::LittleEndian)
    m.message = string[20..string.size]
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

  def make_header
    header_io = IO::Memory.new
    header_io.write_bytes(type, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(session_id, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(unknown1, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(unknown2, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(magic, IO::ByteFormat::LittleEndian)
    header_io.write_bytes(self.message.size, IO::ByteFormat::LittleEndian)

    header_io.to_s
  end

  def make : String
    (make_header + self.message)
  end
end