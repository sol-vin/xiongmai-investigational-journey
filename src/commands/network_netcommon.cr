class Command::Network::NetCommon::Request < XMMessage
  def initialize(magic = 0x05fa_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message: "")
  end
end

class Command::Network::NetCommon::Response < XMMessage
  def initialize(magic = 0x05fb_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "NetWork.NetCommon"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end