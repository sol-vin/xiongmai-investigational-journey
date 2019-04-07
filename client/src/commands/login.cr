require "../dahua_hash"

class Command::Login < Command
  def initialize(@user = "", @password = "", @hash_password = true)
    super(0xe8_u8, 0x03_u8, JSON.build do |json|
      json.object do
        json.field "UserName", @user
        json.field "PassWord", (@hash_password ? Dahua.digest(@password) : @password)
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