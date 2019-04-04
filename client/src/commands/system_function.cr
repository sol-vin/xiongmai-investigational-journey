class Command::SystemFunction < Command
  def initialize(@session_id = 0)
    super(magic1: 0x50_u8, magic2: 0x05_u8, json: JSON.build do |json|
      json.object do
        json.field "Name", "SystemFunction"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end

# magic1: 0x50
# magic2: 0x05
#
# {
# 	"Name":	"SystemFunction",
# 	"SessionID":	"0x0000000007"
# }
# GOT RET 100