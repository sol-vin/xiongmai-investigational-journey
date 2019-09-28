
# TODO: MAY BE VULNERABLE TO WRONG TYPE!
class Command::Network::NetCommon::Request < XMMessage
  def initialize(magic = 0x05fa_u16, session_id = 0_u32)
    super(type: 0x000000ff, magic: magic, session_id: session_id, message: "")
  end
end

class Command::Network::NetCommon::Response < XMMessage
  FUNCTION_NAME = "NetWork.NetCommon"
  CHANNEL_NUM = 1
  DEVICE_TYPE = 1
  HOSTNAME = "LocalHost"
  HTTP_PORT = 80
  MAX_BPS = 0
  MON_MODE = "TCP"
  NET_CONNECT_STATE = 0
  OTHER_FUNCTION = "D=2019-01-01 00:00:00 V=c81a720f25e258c" # V Constantly changes randomly. Maybe we can leave it out
  SSL_PORT = 8443
  TCP_MAX_CONN = 10
  USE_HS_DOWNLOAD = false #TODO: Wtf does this do?
  SUCCESS = 100
  
  def initialize(magic = 0x05fb_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message: JSON.build do |json|
      json.object do
        json.field "Name", "NetWork.NetCommon"
        json.field "NetWork.NetCommon", json.object do |json|
          json.field "ChannelNum", 1
          json.field "DeviceType", 1
          json.field "Gateway", 1
          json.field "HostIP", 1
          json.field "Hostname", "LocalHost"
          json.field "HttpPort", 80
          json.field "MAC", 1
          json.field "MaxBPS", 0
          json.field "MonMode", "TCP"
          json.field "NetConnectState", 0
          json.field "OtherFunction", "D=2019-02-28 17:30:58 V=92a9902100ec7c4"
          json.field "SN", "41e6853ada5e9323"
          json.field "SSLPort", 8443
          json.field "Submask", 0
          json.field "TCPMaxConn", 10
          json.field "TCPPort" : 34567
          json.field "TransferPlan" : "Quality"
          json.field "UDPPort" : 34568
          json.field "UseHSDownLoad" : false
        end
        json.field "Ret", 100
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

# TODO: WRITE DoS FOR THIS! WRONG TYPE VULNERABILITY APPLIES HERE!
# { 
#   "NetWork.NetCommon" : { 
#     "ChannelNum" : 1, 
#     "DeviceType" : 1, 
#     "GateWay" : "0x010BA8C0", 
#     "HostIP" : "0x6D0BA8C0", 
#     "HostName" : "LocalHost", 
#     "HttpPort" : 80, 
#     "MAC" : "00:12:31:08:bb:97", 
#     "MaxBps" : 0, 
#     "MonMode" : "TCP", 
#     "NetConnectState" : 0, 
#     "OtherFunction" : "D=2019-02-28 17:30:58 V=92a9902100ec7c4", 
#     "SN" : "41e6853ada5e9323", 
#     "SSLPort" : 8443, 
#     "Submask" : "0x00FFFFFF", 
#     "TCPMaxConn" : 10, 
#     "TCPPort" : 34567, 
#     "TransferPlan" : "Quality", 
#     "UDPPort" : 34568, 
#     "UseHSDownLoad" : false 
#     }, 
#   "Ret" : 100, 
#   "SessionID" : "0x00000000" 
# }