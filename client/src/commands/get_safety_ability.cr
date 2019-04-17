class Command::GetSafetyAbility < XMMessage
  def initialize(magic = 0x0672_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "GetSafetyAbility"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end


# magic1: 0x72 
# magic2: 0x06
#
# {
# 	"Name":	"GetSafetyAbility",
# 	"SessionID":	"0x0000000000"
# }
# GOT RET 103