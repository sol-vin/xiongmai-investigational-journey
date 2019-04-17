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






# File.open("../besder_resources/logs/users/user/camera_param.log", "w") do |file|
#   Fuzzer.run(
#     Command::CameraParam,
#     magic2: (0x3..0x8), 
#     username: "default",
#     password: "tluafed",
#     output: file
#     )    
# end


