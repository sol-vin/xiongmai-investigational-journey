class Command::OPTimeQuery < XMMessage
  #TODO:! ADD TIME
  def initialize(magic = 0x05AC_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "OPTimeQuery"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end