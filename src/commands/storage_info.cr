class Command::StorageInfo::Request < XMMessage
  def initialize(command = 0x03fc_u16, @session_id = 0_u32)
    super(command: command, message:  JSON.build do |json|
      json.object do
        json.field "Name", "StorageInfo"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

class Command::StorageInfo::Response < XMMessage
  def initialize(command = 0x03fd_u16, @session_id = 0_u32)
    super(command: command, message:  JSON.build do |json|
      json.object do
        json.field "Name", "StorageInfo"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

# "StorageInfo": [
# {
# "PartNumber": 1,
# "Partition": [
# {
# "DirverType": 0,
# "IsCurrent": true,
# "LogicSerialNo": 0,
# "NewEndTime": "2009-02-16 11:52:05",
# "NewStartTime": "2000-11-30 10:58:42",
# "OldEndTime": "2063-11-30 00:00:23",
# "OldStartTime": "2000-00-00 00:00:00",
# "RemainSpace": "0x00073130",
# "Status": 0,
# "TotalSpace": "0x000746FC"
# },
# {
# "DirverType": 0,
# "IsCurrent": false,
# "LogicSerialNo": 0,
# "NewEndTime": "0000-00-00 00:00:00",
# "NewStartTime": "0000-00-00 00:00:00",
# "OldEndTime": "0000-00-00 00:00:00",
# "OldStartTime": "0000-00-00 00:00:00",
# "RemainSpace": "0x00000000",
# "Status": 0,
# "TotalSpace": "0x00000000"
# }
# ],
# "PlysicalNo": 0
# }
# ]
# }