class Command::WorkState::Request < XMMessage
  def initialize(command = 0x03fc_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "WorkState"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').upcase}"
      end
    end)
  end
end

class Command::WorkState::Response < XMMessage
  def initialize(command = 0x03fd_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "WorkState"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').upcase}"
      end
    end)
  end
end

# "WorkState":
# {
# "AlarmState":
# {
# "AlarmIn": 8,
# "AlarmOut": 1,
# "VideoBlind": 0,
# "VideoLoss": 1,
# "VideoMotion": 0
# },
# "ChannelState":
# [
# { "Bitrate": 13, "Record": false},
# { "Bitrate": 9, "Record": false},
# { "Bitrate": 14, "Record": false},
# { "Bitrate": 13, "Record": false},
# { "Bitrate": 14, "Record": false},
# { "Bitrate": 14, "Record": false},
# { "Bitrate": 13, "Record": false},
# { "Bitrate": 9, "Record": false},
# ]
# }
# }