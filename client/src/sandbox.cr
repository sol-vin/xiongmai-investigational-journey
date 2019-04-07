require "json"
require "socket"

require "./fuzzer"
require "./brute"


#puts Dahua.digest("tluafed")
#Brute.run("OxhlwSG8")

# File.open("logs/system_info.log", "w") do |file|
#   Fuzzer.run(
#     Command::SystemInfo.new(session_id: 0x11111117), 
#     magic2: (0x3..0x6), 
#     password: "password",
#     output: file
#     )    
# end