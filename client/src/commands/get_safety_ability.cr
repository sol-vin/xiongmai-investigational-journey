class Command::GetSafetyAbility < Command
  def initialize(@session_id = 0)
    super(magic1: 0x72_u8, magic2: 0x06_u8, json: JSON.build do |json|
      json.object do
        json.field "Name", "GetSafetyAbility"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
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