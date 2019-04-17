class Command::SystemFunction < XMMessage
  def initialize(magic = 0x0550_u16, @session_id = 0_u32)
    super(magic: magic, message:  JSON.build do |json|
      json.object do
        json.field "Name", "SystemFunction"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

# magic1: 0x50
# magic2: 0x05
#
# {
# 	"Name":	"SystemFunction",
# 	"SessionID":	"0x0000000007"
# }
# GOT RET 100