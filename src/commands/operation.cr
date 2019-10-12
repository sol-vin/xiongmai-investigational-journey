module Command::Operation::Monitor
  COMBIN_MODES = ["CONNECT_ALL", "NONE"]
  ACTIONS      = ["Claim"]
  ACTION1S     = ["Start", "Stop", "Claim"]
  STREAM_TYPES = ["Main", "Extra1"]
  TRANS_MODES  = ["TCP"]
end


class Command::Operation::Monitor::Request < XMMessage
  def initialize(command = 0x0585_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPMonitor"
        json.field "OPMonitor" do
          json.object do
            json.field "Action", "Claim"
            json.field "Parameter" do
              json.object do
                json.field "Channel", 0
                json.field "CombinMode", "NONE"
                json.field "StreamType", "Main"
                json.field "TransMode", "TCP"
              end
            end
          end
        end
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::Monitor::Response < XMMessage
  def initialize(command = 0x0586_u16, ret = 100, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPMonitor"
        json.field "Ret", ret
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::LogoSetting::Request < XMMessage
  def initialize(command = 0x0000_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPLogoSetting"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end


class Command::Operation::LogoSetting::Response < XMMessage
  def initialize(command = 0x0000_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPLogoSetting"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::Playback::Request < XMMessage
  def initialize(command = 0x0590_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPPlayback"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::Playback::Response < XMMessage
  def initialize(command = 0x0591_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPPlayback"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

# "Name": "OPPlayBack",
# "OPPlayBack":   {
#     "Action":   "Start",
#     "Parameter":    {
#         "FileName": "/idea0/2015-10-20/001/00.00.00-00.00.09[H][@bff][0].h264",
#         "PlayMode": "ByTime",
#         "Stream_Type":  2,
#         "Value":    0,
#         "TransMode":    "TCP"
#     },
#     "EndTime":  "2016-05-24 23:59:59",
#     "StartTime":    "2016-05-24 00:30:00"
# },
# "SessionID":    "0x000000001f"
# }

class Command::Operation::RecordSnap::Request < XMMessage
  def initialize(command = 0x07fc_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPRecordSnap"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end


class Command::Operation::RecordSnap::Response < XMMessage
  def initialize(command = 0x07fd_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPRecordSnap"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::Talk::Request < XMMessage
  def initialize(command = 0x059A_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPTalk"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::Talk::Response < XMMessage
  def initialize(command = 0x059B_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPTalk"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::TimeQuery::Request < XMMessage
  # TODO:! ADD TIME
  def initialize(command = 0x05AC_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPTimeQuery"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::TimeQuery::Request < XMMessage
  # TODO:! ADD TIME
  def initialize(command = 0x05AD_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPTimeQuery"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

# TODO: Fix this
class Command::Operation::TimeSettingNoRTC::Request < XMMessage
  # TODO:! ADD TIME
  def initialize(command = 0x03ee_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPTimeSettingNoRTC"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

# "{ \"Name\" : \"OPTimeSettingNoRTC\", \"OPTimeSettingNoRTC\" : \"20140313 08:03:07\", \"SessionID\" : \"0x89\" }\n";

class Command::Operation::VersionList::Request < XMMessage
  def initialize(command = 0x0000_u16, @session_id = 0_u32)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPVersionList"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(10, '0')}"
      end
    end)
  end
end

class Command::Operation::VersionList::Response < XMMessage
  def initialize(command = 0x0000_u16, @session_id = 0_u32)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPVersionList"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(10, '0')}"
      end
    end)
  end
end

class Command::Operation::ReqVersion::Request < XMMessage
  def initialize(command = 0x0000_u16, @session_id = 0_u32)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPReqVersion"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(10, '0')}"
      end
    end)
  end
end

class Command::Operation::ReqVersion::Response < XMMessage
  def initialize(command = 0x0000_u16, @session_id = 0_u32)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPReqVersion"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(10, '0')}"
      end
    end)
  end
end

class Command::Operation::VersionReq::Request < XMMessage
  def initialize(command = 0x0000_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPVersionReq"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::VersionReq::Response < XMMessage
  def initialize(command = 0x0000_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPVersionReq"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::VersionRep::Request < XMMessage
  def initialize(command = 0x0000_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPVersionRep"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::VersionRep::Response < XMMessage
  def initialize(command = 0x0000_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPVersionRep"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::SCalendar::Request < XMMessage
  def initialize(command = 0x05a6_u16, @session_id = 0_u32)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPSCalendar"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::Machine::Request < XMMessage
  def initialize(command = 0x05aa_u16, @session_id = 0_u32, reboot = false)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPMachine"
        if reboot
          json.field "OPMachine" do
            json.object do
              json.field "Action", "Reset"
            end
          end
        end
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::DefaultConfig::Request < XMMessage
  def initialize(command = 0x05aa_u16, @session_id = 0_u32)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPDefaultConfig"
        json.field "OPDefaultConfig" do
          json.object do
            json.field "Account", true
            json.field "Alarm", true
            json.field "CommPtz", true
            json.field "Encode", true
            json.field "General", true
            json.field "NetCommon", true
            json.field "NetServer", true
            json.field "Preview", true
            json.field "Record", true
          end
        end
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::SystemUpgrade::Request < XMMessage
  # "{ \"Name\" : \"OPSystemUpgrade\", \"OPSystemUpgrade\" : { \"Hardware\" : \"HI3516EV100_50H20L_S38\", \"LogoArea\" : { \"Begin\" : \"0x80770000\", \"End\" : \"0x80780000\" }, \"LogoPartType\" : \"\", \"Serial\" : \"\", \"Vendor\" : \"General\" }, \"Ret\" : 100, \"SessionID\" : \"0x0\" }\n"
  #     Bytes: ["0x05f5"]
  def initialize(command = 0x05f5_u16, @session_id = 0_u32)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPSystemUpgrade"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end


class Command::Operation::SystemUpgrade::Response < XMMessage
  # "{ \"Name\" : \"OPSystemUpgrade\", \"OPSystemUpgrade\" : { \"Hardware\" : \"HI3516EV100_50H20L_S38\", \"LogoArea\" : { \"Begin\" : \"0x80770000\", \"End\" : \"0x80780000\" }, \"LogoPartType\" : \"\", \"Serial\" : \"\", \"Vendor\" : \"General\" }, \"Ret\" : 100, \"SessionID\" : \"0x0\" }\n"
  #     Bytes: ["0x05f5"]
  def initialize(command = 0x05f5_u16, @session_id = 0_u32)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPSystemUpgrade"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::SystemUpgrade2::Request < XMMessage
  # "{ \"Name\" : \"OPSystemUpgrade\", \"Ret\" : 103, \"SessionID\" : \"0x00000000\" }\n"
  #     Bytes: ["0x05f0"]
  def initialize(command = 0x05f0_u16, @session_id = 0_u32)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPSystemUpgrade"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::SystemUpgrade2::Response < XMMessage
  # "{ \"Name\" : \"OPSystemUpgrade\", \"Ret\" : 103, \"SessionID\" : \"0x00000000\" }\n"
  #     Bytes: ["0x05f0"]
  def initialize(command = 0x05f0_u16, @session_id = 0_u32)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPSystemUpgrade"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::NetAlarm::Request < XMMessage
  # "{ \"Name\" : \"OPNetAlarm\", \"Ret\" : 100, \"SessionID\" : \"0x00000000\" }\n"
  # Bytes: ["0x05e2"]
  def initialize(command = 0x05e2_u16, @session_id = 0_u32)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPNetAlarm"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

class Command::Operation::NetAlarm::Response < XMMessage
  def initialize(command = 0x05e3_u16, ret = 100, @session_id = 0_u32)
    super(command: command, message: JSON.build do |json|
      json.object do
        json.field "Name", "OPNetAlarm"
        json.field "Ret", ret
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end
