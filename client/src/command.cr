class Command
  getter magic1 : UInt8
  getter magic2 : UInt8
  getter json : String

  def initialize(@magic1, @magic2, @json)
  end

  def initialize(magic1 = 0, magic2 = 0, @json = "")
    @magic1 = magic1.to_u8
    @magic2 = magic2.to_u8
  end

  def make_header
    session_id = 0

    unless self.json.empty?
      parsed = JSON.parse self.json
      if parsed["SessionID"]?
        session_id = parsed["SessionID"].to_s[2..10].to_i(16)
      end
    end 

    session_io = IO::Memory.new
    session_io.write_bytes(session_id, IO::ByteFormat::LittleEndian)

    size_io = IO::Memory.new
    size_io.write_bytes(self.json.size, IO::ByteFormat::LittleEndian)

    "\xff\x01\x00\x00#{session_io.to_s}\x00\x00\x00\x00\x00\x00" +
    "#{String.new(Bytes[self.magic1])}#{String.new(Bytes[self.magic2])}#{size_io.to_s}"
  end

  def make : String
    (make_header + self.json)
  end
end






#   getter system_info = 

#   system_info_mb1 = 0xe8
#   system_info_mb2 = 0x03

#   system_function = JSON.build do |json|
#     json.object do
#       json.field "Name", "SystemFunction"
#       json.field "SessionID", "0x11111117"    
#     end
#   end
#   system_function_mb1 = 0x50
#   system_function_mb2 = 0x05

#   general_general = JSON.build do |json|
#     json.object do
#       json.field "Name", "General.General"
#       json.field "SessionID", "0x11111117"    
#     end
#   end
#   general_general_mb1 = 0x14
#   general_general_mb1_null = 0x12
#   general_general_mb2 = 0x04

#   uart_ptz = JSON.build do |json|
#     json.object do
#       json.field "Name", "Uart.PTZ"
#       json.field "SessionID", "0x11111117"    
#     end
#   end
#   system_function_mb1 = 0x50
#   system_function_mb2 = 0x05
# end