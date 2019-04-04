class Command::OPTimeSettingNoRTC < Command
  #TODO:! ADD TIME
  def initialize(@session_id = 0)
    super(magic1: 0xee_u8, magic2: 0x03_u8, json: JSON.build do |json|
      json.object do
        json.field "Name", "OPTimeSettingNoRTC"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end

#"{ \"Name\" : \"OPTimeSettingNoRTC\", \"OPTimeSettingNoRTC\" : \"20140313 08:03:07\", \"SessionID\" : \"0x89\" }\n";