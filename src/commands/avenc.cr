class Command::AVEnc::SmartH264::Request < XMMessage
  def initialize(command = 0x0410_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.SmartH264"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::SmartH264::Response < XMMessage
  def initialize(command = 0x0411_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.SmartH264"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

# Request
# {
# 	"Name":	"AVEnc.SmartH264",
# 	"AVEnc.SmartH264":	[{
# 			"SmartH264":	false
# 		}],
# 	"SessionID":	"0x0000000001"
# }

# Reply
# {
# 	"Name":	"AVEnc.SmartH264",
# 	"SessionID":	"0x0000000001"
# }
