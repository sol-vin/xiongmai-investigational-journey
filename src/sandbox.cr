require "json"
require "socket"
require "./dahua_hash"
require "./magic_fuzzer/magic_fuzzer"
require "./xm_magic_fuzzer"

# XMMagicFuzzer.run
sock_is_up = false

until sock_is_up
  begin
    sock = XMSocketTCP.new("192.168.1.99", 34567)
    sock.read_timeout = 5
    sock.login("admin", Dahua.digest "password")
    sock_is_up = true

    xmm = Command::GetSafetyAbility::Request.new
    counter = 0
    start = Time.now

    begin
      loop do
        sock.send_message xmm
        msg = sock.receive_message.message
        puts "#{counter} #{msg}"
        counter += 1
        sleep 0.5
      end
    rescue e : XMError::ReceiveTimeout
      puts "Was up for #{counter} times, #{Time.now - start}"
    end
  rescue e
    puts "(LOGIN) Error #{e}"
    sleep 1
  end
end

# xmm = Command::EncodeCapability::Request.new(session_id: 1_u32)
# sock.send_message xmm
# puts sock.receive_message.message
