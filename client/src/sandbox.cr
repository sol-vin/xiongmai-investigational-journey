require "json"
require "socket"

require "./fuzzer"

system_info = JSON.build do |json|
  json.object do
    json.field "Name", "SystemInfo"
    json.field "SessionID", "0x11111117"
  end
end

blank_name = JSON.build do |json|
  json.object do
    json.field "Name", ""
    json.field "SessionID", "0x11111117"
  end
end

blank_session_and_name = JSON.build do |json|
  json.object do
    json.field "Name", ""
    json.field "SessionID", ""
  end
end

no_name = JSON.build do |json|
  json.object do
    json.field "SessionID", "0x11111117"
  end
end

no_session = JSON.build do |json|
  json.object do
    json.field "Name", "SystemInfo" 
  end
end

random_name = JSON.build do |json|
  json.object do
    json.field "Name", "BLAHBLAHBLAH"
    json.field "SessionID", "0x11111117"    
  end
end

(0x0..0xFF).each do |weird_byte2|
  puts "0x#{weird_byte2.to_s(16).rjust(2, '0')}"
  File.open("logs/output-#{weird_byte2.to_s.rjust(3, '0')}-#{weird_byte2.to_s(16).rjust(2, '0')}.log", "w") do |file|
    Fuzzer.run_no_auth_fuzz(system_info, weird_byte2: weird_byte2, output: file)
    file.flush
  end
end


#Fuzzer.run_auth_command(system_info, 0xe2, 0x5)
# puts Fuzzer.run_auth_command(system_info, "password", 0xf1, 0x5)
# sleep 0.1
# Fuzzer.run_auth_command(system_info, "password", 0xf1, 0x5)

# File.open("output.zip", "w") do |file|
#   file.puts Fuzzer.run_auth_command(system_info, "password", weird_byte1: 0x6c, weird_byte2: 0x06)
#   file.flush
# end