require "json"
require "socket"

require "./magic_fuzzer"
require "./fuzzer"
require "./brute"



# File.open("./logs/system_info.log", "w") do |file|
#   Fuzzer.run(
#     Command::SystemInfo,
#     magic2: (0x3..0x8),
#     username: "admin",
#     password: Dahua.digest("password"),
#     output: file
#     )    
# end

File.open("./logs/test.log", "w") do |file|
  m = MagicFuzzer.new(
    Command::SystemInfo,
    magic: (0x03E0..0x04FF), 
    username: "admin",
    password: "password",
    output: file
    )  
  m.run
  m.wait_until_done
  m.report
  m.close
end
















# File.open("../besder_resources/logs/users/user/camera_param.log", "w") do |file|
#   Fuzzer.run(
#     Command::CameraParam,
#     magic2: (0x3..0x8), 
#     username: "default",
#     password: "tluafed",
#     output: file
#     )    
# end







# CLEAR_SCREEN = "\e[H\e[2J"

# private def clear_screen
#   puts CLEAR_SCREEN
# end

# channel = Channel(Int32).new

# puts "START!"

# a = [] of Int32

# spawn do
#   0x10000.times do |x|
#     a << channel.receive
#   end
# end

# spawn do
#   sleep 3
#   0x10000.times do |x|
#     clear_screen
#     puts a.shift
#   end
# end

# 0x10000.times do |x|
#   channel.send x
# end

# sleep 100


