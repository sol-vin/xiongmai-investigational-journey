require "json"
require "socket"

require "./fuzzer"

system_info = JSON.build do |json|
  json.object do
    json.field "Name", "SystemInfo"
    json.field "SessionID", "0x11111117"
  end
end

File.open("output.log", "w") do |file|
  Fuzzer.run_auth_fuzz(system_info, "password", weird_byte2: 0xF1, output: file)
  file.flush
end


#Fuzzer.run_auth_command(system_info, 0xe2, 0x5)
# puts Fuzzer.run_auth_command(system_info, "password", 0xf1, 0x5)
# sleep 0.1
# Fuzzer.run_auth_command(system_info, "password", 0xf1, 0x5)

# File.open("output.zip", "w") do |file|
#   file.puts Fuzzer.run_auth_command(system_info, "password", weird_byte1: 0x6c, weird_byte2: 0x06)
#   file.flush
# end