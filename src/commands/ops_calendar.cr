class Command::OPSCalendar < XMMessage
  def initialize(magic = 0x05a6_u16, @session_id = 0_u32)
    super(magic: magic, message:  JSON.build do |json|
      json.object do
        json.field "Name", "OPSCalendar"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end