class Command::SystemInfo < XMMessage
  def initialize(magic = 0x03fc_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "SystemInfo"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').upcase}"
      end
    end)
  end
end