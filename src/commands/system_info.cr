class Command::SystemInfo::Request < XMMessage
  def initialize(command = 0x03fc_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "SystemInfo"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').upcase}"
      end
    end)
  end
end

class Command::SystemInfo::Response < XMMessage
  def initialize(command = 0x03fd_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "SystemInfo"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').upcase}"
        json.field "Ret", 100
        json.field "SystemInfo" do
          json.field "AlarmInChannel", 8
          json.field "AlarmOutChannel", 2
          json.field "BuildTime", "2009-02-13 12:03:12"
          json.field "EncryptVersion", "Unknown"
          json.field "HardWareVersion", "Unknown"
          json.field "SerialNo", "00000000"
          json.field "SoftWareVersion", "JF1.00.R01"
          json.field "TalkInChannel", 1
          json.field "TalkOutChannel", 1
          json.field "VideoInChannel", 8
          json.field "VideoOutChannel", 1
          json.field "ExtraChannel", 1
          json.field "AudioInChannel", 4
          json.field "DeviceRunTime", "0x0000019A"
        end
      end
    end)
  end
end