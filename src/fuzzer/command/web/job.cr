class Command::Fuzzer::Job
  property name : String = ""
  property target : String = ""
  property port : UInt16 = 0
  property uuid : UUID = UUID.random
  property commands : Range(UInt16, UInt16) = (0x03e0_u16..0x08FF_u16)
  property username = "admin"
  property password = ""
  property hash_password = true
  property login = true
  property template = Command::GetSafetyAbility::Request.new
  property fuzzer : Command::Fuzzer = Command::Fuzzer.new
  property? started = false
  property? stopped = false
  getter create_time = Time.now
  getter start_time = Time.new(1970, 1, 1, 0, 0, 0)


  def initialize()
  end

  def start
    if !started?
      @started = true
      @start_time = Time.now
      @fuzzer = Command::Fuzzer.new(
        commands, username, password, hash_password, login, target, template
      )

      @fuzzer.run
    end
  end

  def stop
    if started? && !stopped?
      @stopped = true
      @fuzzer.close
    end
  end
end