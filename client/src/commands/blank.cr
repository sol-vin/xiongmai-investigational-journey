class Command::Blank < XMMessage
  def initialize(magic = 0_u16, session_id = 0)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", ""
      end
    end)
  end
end

class Command::BlankWithSession < XMMessage
  def initialize(magic = 0_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", ""
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

class Command::NoName < XMMessage
  def initialize(magic = 0_u16,  session_id = 0_u32)
    super(magic: magic, session_id: session_id,message:  JSON.build do |json|
      json.object do
      end
    end)
  end
end

class Command::NoNameWithSession < XMMessage
  def initialize(magic = 0_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id,message:  JSON.build do |json|
      json.object do
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end

class Command::RandomName < XMMessage
  def initialize(magic = 0_u16, session_id = 0_u32)
    super(magic: magic, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "ABCDEFG"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(8, '0').capitalize}"
      end
    end)
  end
end