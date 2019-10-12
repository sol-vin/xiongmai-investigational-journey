require "../dahua_hash"

module Command::Login
  TYPES = [
    "GUI",
    "Console",
    "DVRIP-Web",
    "DVRIP-SNS",
    "DVRIP-Mobile",
    "DVRIP-Server",
    "DVRIP-Upgrade",
    "DVRIP-AutoSearch",
    "DVRIP-NetKeyboard",
    "DVRIP-Xm030"
  ]

  CRYPTO = ["None", "MD5", "3DES"]
  DEVICE_TYPES = ["DVR", "DVS", "IPC"]
end

class Command::Login::Request < XMMessage
  SUCCESS = 100
  UNKNOWN = 106
  FAILURE = 205



  def initialize(command = 0x03e8_u16, session_id = 0_u32, @username = "", @password = "")
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "EncryptType", "MD5"
        json.field "LoginType", "DVRIP-Xm030"
        json.field "UserName", @username
        json.field "PassWord", @password
      end
    end)
  end
end

class Command::Login::Response < XMMessage
  SUCCESS = 100
  UNKNOWN = 106
  FAILURE = 205

  def initialize(command = 0x03e9_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "AliveInterval", 20
        json.field "ChannelNum", 1
        json.field "DeviceType", "IPC"
        # TODO: Test device id
        # json.field "DeviceID", 123456
        json.field "Ret", 100
        json.field "SessionID", "0x00000000"
      end
    end)
  end
end

class Command::Login::NoPasswordRequest < XMMessage
  SUCCESS = 100
  UNKNOWN = 106
  FAILURE = 205

  def initialize(command = 0x03e8_u16, session_id = 0_u32, @username = "")
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "EncryptType", "MD5"
        json.field "LoginType", "DVRIP-Xm030"
        json.field "UserName", @username
      end
    end)
  end
end

class Command::Login::NoUsernameRequest < XMMessage
  SUCCESS = 100
  UNKNOWN = 106
  FAILURE = 205

  def initialize(command = 0x03e8_u16, session_id = 0_u32, @password = "")
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "EncryptType", "MD5"
        json.field "LoginType", "DVRIP-Xm030"
        json.field "PassWord", @password
      end
    end)
  end
end

class Command::Login::NoCredsRequest < XMMessage
  SUCCESS = 100
  UNKNOWN = 106
  FAILURE = 205

  def initialize(command = 0x03e8_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "EncryptType", "MD5"
        json.field "LoginType", "DVRIP-Xm030"
      end
    end)
  end
end

class Command::Logout::Request < XMMessage
  SUCCESS = 100
  UNKNOWN = 106
  FAILURE = 205

  def initialize(command = 0x03ea_u16, session_id = 0_u32, @username = "", @password = "")
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", ""
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

class Command::Logout::Response < XMMessage
  SUCCESS = 100
  UNKNOWN = 106
  FAILURE = 205

  def initialize(command = 0x03eb_u16, session_id = 0_u32, @username = "", @password = "")
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
      end
    end)
  end
end