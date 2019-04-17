require "../dahua_hash"

class Command::Login < XMMessage
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

# login_original = JSON.build do |json|
#   json.object do
#     json.field "EncryptType", "MD5"
#     json.field "LoginType", "DVRIP-Xm030"
#     json.field "UserName", "admin"
#     json.field "PassWord", Dahua.digest(password)
#   end
# end
