class Command::OPTimeSettingNoRTC < Command
  #TODO:! ADD TIME
  def initialize(magic = 0x03ee_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, json: JSON.build do |json|
      json.object do
        json.field "Name", "OPTimeSettingNoRTC"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

#"{ \"Name\" : \"OPTimeSettingNoRTC\", \"OPTimeSettingNoRTC\" : \"20140313 08:03:07\", \"SessionID\" : \"0x89\" }\n";