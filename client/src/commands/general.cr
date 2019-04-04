class Command::General < Command
  def initialize(@session_id = 0)
    super(0x14_u8, 0x04_u8, JSON.build do |json|
      json.object do
        json.field "Name", "General.General"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end

class Command::GeneralNull < Command
  def initialize(@session_id = 0)
    super(0x12_u8, 0x04_u8, JSON.build do |json|
      json.object do
        json.field "Name", "General.General"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end