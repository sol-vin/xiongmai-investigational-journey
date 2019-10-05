class Command::AVEnc::SmartH264::Set::Request < XMMessage
  def initialize(command = 0x0410_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.SmartH264"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::SmartH264::Set::Response < XMMessage
  def initialize(command = 0x0411_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.SmartH264"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

# Request
# {
# 	"Name":	"AVEnc.SmartH264",
# 	"AVEnc.SmartH264":	[{
# 			"SmartH264":	false
# 		}],
# 	"SessionID":	"0x0000000001"
# }

# Reply
# {
# 	"Name":	"AVEnc.SmartH264",
# 	"SessionID":	"0x0000000001"
# }

class Command::AVEnc::SmartH264::Get::Request < XMMessage
  def initialize(command = 0x0412_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.SmartH264"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::SmartH264::Get::Response < XMMessage
  def initialize(command = 0x0413_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.SmartH264"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::SmartH264::Get::Default::Request < XMMessage
  def initialize(command = 0x0414_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.SmartH264"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::SmartH264::Get::Default::Response < XMMessage
  def initialize(command = 0x0415_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.SmartH264"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end




class Command::AVEnc::Encode::Set::Request < XMMessage
  def initialize(command = 0x0410_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.Encode"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::Encode::Set::Response < XMMessage
  def initialize(command = 0x0411_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.Encode"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::Encode::Get::Request < XMMessage
  def initialize(command = 0x0412_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.Encode"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::Encode::Get::Response < XMMessage
  def initialize(command = 0x0413_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.Encode"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end
class Command::AVEnc::Encode::Get::Default::Request < XMMessage
  def initialize(command = 0x0414_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.Encode"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::Encode::Get::Default::Response < XMMessage
  def initialize(command = 0x0415_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.Encode"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end






class Command::AVEnc::VideoWidget::Set::Request < XMMessage
  def initialize(command = 0x0410_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.VideoWidget"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::VideoWidget::Set::Response < XMMessage
  def initialize(command = 0x0411_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.VideoWidget"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::VideoWidget::Get::Request < XMMessage
  def initialize(command = 0x0412_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.VideoWidget"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::VideoWidget::Get::Response < XMMessage
  def initialize(command = 0x0413_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.VideoWidget"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::VideoWidget::Get::Default::Request < XMMessage
  def initialize(command = 0x0414_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.VideoWidget"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::VideoWidget::Get::Default::Response < XMMessage
  def initialize(command = 0x0415_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.VideoWidget"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end






class Command::AVEnc::VideoColor::Set::Request < XMMessage
  def initialize(command = 0x0410_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.VideoColor"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::VideoColor::Set::Response < XMMessage
  def initialize(command = 0x0411_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.VideoColor"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::VideoColor::Get::Request < XMMessage
  def initialize(command = 0x0412_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.VideoColor"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::VideoColor::Get::Response < XMMessage
  def initialize(command = 0x0413_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.VideoColor"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::VideoColor::Get::Default::Request < XMMessage
  def initialize(command = 0x0414_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.VideoColor"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end

class Command::AVEnc::VideoColor::Get::Default::Response < XMMessage
  def initialize(command = 0x0415_u16, session_id = 0_u32)
    super(command: command, session_id: session_id, message:  JSON.build do |json|
      json.object do
        json.field "Name", "AVEnc.VideoColor"
        json.field "SessionID", "0x#{session_id.to_s(16).rjust(10, '0').capitalize}"
      end
    end)
  end
end
