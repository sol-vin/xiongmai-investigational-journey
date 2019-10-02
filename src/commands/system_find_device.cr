class Command::SystemFindDevice < XMMessage
  def initialize(command = 0x0000_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "System.FindDevice"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end