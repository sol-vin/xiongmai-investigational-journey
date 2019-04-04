class Command::CameraParam < Command
  def initialize(@session_id = 0)
    super(magic1: 0x14_u8, magic2: 0x04_u8, json: JSON.build do |json|
      json.object do
        json.field "Name", "Camera.Param"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end

class Command::CameraParamEx < Command
  def initialize(@session_id = 0)
    super(magic1: 0x14_u8, magic2: 0x04_u8, json: JSON.build do |json|
      json.object do
        json.field "Name", "Camera.ParamEx"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end