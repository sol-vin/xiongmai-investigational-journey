require "json"
require "socket"

require "./magic_fuzzer"

File.open("./logs/test.log", "w+") do |file|
  m = MagicFuzzer(Command::SystemInfo).new(
    magic: (0x0000..0x1000),
    username: "admin",
    password: "password",
    output: file
    )
  m.run
  m.wait_until_done
  m.report
  m.close
end

# xmm.magic = 0x03f1 # LOGOUT?
# xmm.magic = 0x03fc # LOGOUT?
# xmm.magic = 0x041c # LOGOUT?
# xmm.magic = 0x0586 # LOGOUT?
# xmm.magic = 0x0598 # LOGOUT?
# xmm.magic = 0x059c # LOGOUT?
# xmm.magic = 0x05a4 # LOGOUT?
# xmm.magic = 0x05aa # LOGOUT?
# xmm.magic = 0x05d2 # LOGOUT?
# 0x6ec : Logout
# 0x6f0
# xmm.magic = 0x07de
# 0x07d0
# 0x07da
# 0x07db
# xmm.magic = 0x07e4
# 0x07ef
# 0x07f0
# 0x07f2
# 0x07fa

# BINGO! xmm.magic = 0x0678 # DOS DOS!
# 0x07f6

# xmm = Command::NoName.new
# PASSWORD = Dahua.digest("password")
# m = MagicSocket.new("192.168.11.109", 34567)
# m.login("admin", PASSWORD)

# xmm.magic = 0x0000
# m.send_message xmm
# puts m.receive_message.message

# xmm.magic = 0x0550
# m.send_message xmm
# puts m.receive_message.message

# (0x2f00..0xFFFF).each do |x|
#   xmm.magic = x.to_u16

#   begin
#     print '.' if x % 0x100 == 0
#     m.send_message xmm
#     m.receive_message.message
#   rescue e
#     puts "#{x} : #{e}"
#     raise e
#   end
# end

# xmm.magic = 0x07f6

# m.send_message xmm
# puts m.receive_message.message #.bytes.map{|x| x.to_s(16).rjust(2, '0')}

# xmm.magic = 0x0000

# m.send_message xmm
# puts m.receive_message.message

# File.open("../besder_resources/logs/users/user/camera_param.log", "w") do |file|
#   Fuzzer.run(
#     Command::CameraParam,
#     magic2: (0x3..0x8),
#     username: "default",
#     password: "tluafed",
#     output: file
#     )
# end
