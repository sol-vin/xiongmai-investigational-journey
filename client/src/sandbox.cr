require "json"
require "socket"

require "./fuzzer"



File.open("logs/ops_calendar.log", "w") do |file|
  Fuzzer.run(
    Command::OPSCalendar.new(session_id: 0x11111117), 
    magic2: (0x3..0x6), 
    password: "password",
    output: file
    )    
end