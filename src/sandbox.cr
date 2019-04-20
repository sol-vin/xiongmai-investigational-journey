require "json"
require "socket"

require "./magic_fuzzer"


# File.open("./logs/test.log", "w+") do |file|
#   m = MagicFuzzer(Command::KeepAlive).new(
#     magic: (0x0000..0x1000), 
#     username: "admin",
#     password: "password",
#     output: file
#     )
#   m.run
#   m.wait_until_done
#   m.report
#   m.close
# end

#xmm.magic = 0x03f1 # LOGOUT?
#xmm.magic = 0x03fc # LOGOUT?
#xmm.magic = 0x041c # LOGOUT?
#xmm.magic = 0x0586 # LOGOUT?
#xmm.magic = 0x0598 # LOGOUT?
#xmm.magic = 0x059c # LOGOUT?
#xmm.magic = 0x05a4 # LOGOUT?
#xmm.magic = 0x05aa # LOGOUT?
#xmm.magic = 0x05d2 # LOGOUT?

#BINGO! xmm.magic = 0x0678 # DOS DOS!



xmm = Command::NoName.new
PASSWORD = Dahua.digest("password")
m = MagicSocket.new("192.168.11.109", 34567)
m.login("admin", PASSWORD)


xmm.magic = 0x0000
m.send_message xmm
puts m.recieve_message.message

# (0x0800..0x860).each do |x|
#   xmm.magic = x.to_u16

#   m.send_message xmm
#   puts x.to_s(16) + " : " + m.recieve_message.message
# end

xmm.magic = 0x05d2

m.send_message xmm
puts m.recieve_message.message.bytes.map{|x| x.to_s(16).rjust(2, '0')}


xmm.magic = 0x0000

m.send_message xmm
puts m.recieve_message.message



# File.open("../besder_resources/logs/users/user/camera_param.log", "w") do |file|
#   Fuzzer.run(
#     Command::CameraParam,
#     magic2: (0x3..0x8), 
#     username: "default",
#     password: "tluafed",
#     output: file
#     )    
# end


