class Command::OPPlayback < XMMessage
  def initialize(magic = 0x0590_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "OPPlayback"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
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