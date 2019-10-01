class Command::General::Request < XMMessage
  def initialize(magic = 0x0414_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "General.General"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::GeneralNull::Request < XMMessage
  def initialize(magic = 0x0412_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "General.General"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

# TODO: Something went horribly wrong when fuzzing this command with magic fuzzer, figure it out.
class Command::General::Location::Request < XMMessage
  def initialize(magic = 0x0414_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "General.Location"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end