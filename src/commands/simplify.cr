class Command::Simplify::Encode::Request < XMMessage
  def initialize(magic = 0x0412_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "Simplify.Encode"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Simplify::Encode::Response < XMMessage
  def initialize(magic = 0x0413_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "Simplify.Encode"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end
