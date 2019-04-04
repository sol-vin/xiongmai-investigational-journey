class Command::OPVersionList < Command
  def initialize(@session_id = 0)
    super(magic1: 0x00_u8, magic2: 0x00_u8, json: JSON.build do |json|
      json.object do
        json.field "Name", "OPVersionList"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end

class Command::OPReqVersion < Command
  def initialize(@session_id = 0)
    super(magic1: 0x00_u8, magic2: 0x00_u8, json: JSON.build do |json|
      json.object do
        json.field "Name", "OPReqVersion"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end

class Command::OPVersionReq < Command
  def initialize(@session_id = 0)
    super(magic1: 0x00_u8, magic2: 0x00_u8, json: JSON.build do |json|
      json.object do
        json.field "Name", "OPVersionReq"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end

class Command::OPVersionRep < Command
  def initialize(@session_id = 0)
    super(magic1: 0x00_u8, magic2: 0x00_u8, json: JSON.build do |json|
      json.object do
        json.field "Name", "OPVersionRep"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end

