class Command::AuthorityList::Request < XMMessage
  def initialize(command = 0x05c2_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AuthorityList"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').upcase}"
      end
    end)
  end
end

class Command::AuthorityList::Response < XMMessage
  def initialize(command = 0x05c3_u16, ret = 100, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AuthorityList"
        json.field "Ret", ret
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').upcase}"
      end
    end)
  end
end