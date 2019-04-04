pp Fuzzer.run_auth_command(
  Command::OPMonitor.new(
    magic1: 0x85,
    session_id: 0x00000000
    ), 
  password: "password"
  )