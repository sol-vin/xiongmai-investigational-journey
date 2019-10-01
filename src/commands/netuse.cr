class Command::NetUse::DigitalLightAbility::Request < XMMessage
  def initialize(magic = 0x0412_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "NetUse.DigitalLightAbility" # Original has .[0], wtf?
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::NetUse::DigitalLightAbility::Response < XMMessage
  def initialize(magic = 0x0413_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        # TODO: Find why the fuck this happened
        json.field "Name", ""
        json.field "Ret", 607
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end


# Request
# {
# 	"Name":	"NetUse.DigitalLightAbility.[0]",
# 	"SessionID":	"0x0000000002"
# }

# Reply
# { "Name" : "", "Ret" : 607, "SessionID" : "0x00000002" }
