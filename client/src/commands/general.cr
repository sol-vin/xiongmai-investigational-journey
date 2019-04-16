class Command::General < Command
  def initialize(magic = 0x0414_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, json: JSON.build do |json|
      json.object do
        json.field "Name", "General.General"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

class Command::GeneralNull < Command
  def initialize(magic = 0x0412_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, json: JSON.build do |json|
      json.object do
        json.field "Name", "General.General"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end