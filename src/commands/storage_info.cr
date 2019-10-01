class Command::StorageInfo::Request < XMMessage
  def initialize(magic = 0x03fc_u16, @session_id = 0_u32)
    super(magic: magic, message:  JSON.build do |json|
      json.object do
        json.field "Name", "StorageInfo"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end