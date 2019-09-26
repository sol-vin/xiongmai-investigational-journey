require "../dahua_hash"

class Command::Login::Request < XMMessage
  SUCCESS = 100
  UNKNOWN = 106
  FAILURE = 205

  def initialize(magic = 0x03e8_u16, session_id = 0_u32, @username = "", @password = "")
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
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

  def initialize(magic = 0x03e9_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "AliveInterval", 20
        json.field "ChannelNum", 1
        json.field "DeviceType", "IPC"
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

  def initialize(magic = 0x03e8_u16, session_id = 0_u32, @username = "")
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
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

  def initialize(magic = 0x03e8_u16, session_id = 0_u32, @password = "")
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
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

  def initialize(magic = 0x03e8_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "EncryptType", "MD5"
        json.field "LoginType", "DVRIP-Xm030"
      end
    end)
  end
end
