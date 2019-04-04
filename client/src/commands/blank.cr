class Command::Blank < Command
  def initialize(magic1 = 0, magic2 = 0)
    super(magic1: magic1, magic2: magic2, json: JSON.build do |json|
      json.object do
        json.field "Name", ""
      end
    end)
  end
end

class Command::BlankWithSession < Command
  def initialize(magic1 = 0xDC, magic2 = 0x05, @session_id = 0)
    super(magic1: magic1, magic2: magic2, json: JSON.build do |json|
      json.object do
        json.field "Name", ""
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end

class Command::NoName < Command
  def initialize(magic1 = 0, magic2 = 0)
    super(magic1: magic1, magic2: magic2, json: JSON.build do |json|
      json.object do
      end
    end)
  end
end

class Command::NoNameWithSession < Command
  def initialize(magic1 = 0, magic2 = 0, @session_id = 0)
    super(magic1: magic1, magic2: magic2, json: JSON.build do |json|
      json.object do
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end

class Command::RandomName < Command
  def initialize(magic1 = 0, magic2 = 0, @session_id = 0)
    super(magic1: magic1, magic2: magic2, json: JSON.build do |json|
      json.object do
        json.field "Name", "ABCDEFG"
        json.field "SessionID", "0x#{@session_id.to_s(16).rjust(8, '0')}"
      end
    end)
  end
end