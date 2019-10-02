class Command::GetSafetyAbility::Request < XMMessage
  def initialize(command = 0x0672_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "GetSafetyAbility"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::GetSafetyAbility::Response < XMMessage
  def initialize(command = 0x0673_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "GetSafetyAbility"
        json.field "Ret", 103
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
        json.field "authorizeStat", nil
      end
    end)
  end
end


# command1: 0x72 
# command2: 0x06
#
# {
# 	"Name":	"GetSafetyAbility",
# 	"SessionID":	"0x0000000000"
# }
# GOT RET 103