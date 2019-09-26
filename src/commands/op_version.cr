class Command::OPVersionList < XMMessage
  def initialize(magic = 0x0000_u16, @session_id = 0_u32)
    super(magic: magic, message:  JSON.build do |json|
      json.object do
        json.field "Name", "OPVersionList"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(10, '0')}"
      end
    end)
  end
end

class Command::OPReqVersion < XMMessage
  def initialize(magic = 0x0000_u16, @session_id = 0_u32)
    super(magic: magic, message:  JSON.build do |json|
      json.object do
        json.field "Name", "OPReqVersion"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(10, '0')}"
      end
    end)
  end
end

class Command::OPVersionReq < XMMessage
  def initialize(magic = 0x0000_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "OPVersionReq"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::OPVersionRep < XMMessage
  def initialize(magic = 0x0000_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "OPVersionRep"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

