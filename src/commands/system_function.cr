class Command::SystemFunction < XMMessage
  def initialize(command = 0x0550_u16, @session_id = 0_u32)
    super(command: command, message:  JSON.build do |json|
      json.object do
        json.field "Name", "SystemFunction"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

# command1: 0x50
# command2: 0x05
#
# {
# 	"Name":	"SystemFunction",
# 	"SessionID":	"0x0000000007"
# }
# GOT RET 100