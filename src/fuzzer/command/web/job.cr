class Command::Fuzzer::Job
  # Name of the job
  property name : String = ""
  # Target IP
  property target : String = ""
  # Target port
  property port : UInt16 = 0
  # UUID used to reference a job
  property uuid : UUID = UUID.random
  # Command range to use
  property commands : Range(UInt16, UInt16) = (0x03e0_u16..0x08FF_u16)
  # Username to access camera
  property username = "admin"
  # Password to access camera
  property password = ""
  # should the password be hashed?
  property hash_password = true
  # Should it login?
  property login = true
  # Template for the fuzzer
  property template : XMMessage = Command::GetSafetyAbility::Request.new
  # First pass fuzzer
  getter fuzzer : Command::Fuzzer = Command::Fuzzer.new
  # Second pass fuzzer
  getter bad_fuzzer : Command::Fuzzer = Command::Fuzzer.new

  # Has the job started?
  getter? started = false
  # Was the job cancelled?
  getter? cancelled = false
  # Has the second phase been started?
  getter? started_bad = false

  # What time was it created
  getter date_created = Time.now
  # What time was it started
  getter date_started = Time.new(1970, 1, 1, 0, 0, 0)
  # What time it was finished
  getter date_finished = Time.new(1970, 1, 1, 0, 0, 0)

  def initialize()
  end

  def start
    if !started?
      @started = true
      @date_started = Time.now
      spawn do
        @fuzzer = Command::Fuzzer.new(
          commands.to_a, username, password, hash_password, login, target, template, 8, 60
        )

        @fuzzer.run
        @fuzzer.wait
        @fuzzer.close

        @started_bad = true
        good_results = fuzzer.results.select(&.good?)
        bad_commands = [] of UInt16
        fuzzer.results.select(&.bad?).sort{|a,b| a.message.command <=> b.message.command}.each do |result|
          bad_commands << result.message.command
        end
        unless bad_commands.empty?
          @bad_fuzzer = Command::Fuzzer.new(
            bad_commands, username, password, hash_password, login, target, template, 1, 140
          )

          @bad_fuzzer.run
          @bad_fuzzer.wait
          @bad_fuzzer.close


          @date_finished = Time.now
        end

        full_results = good_results + @bad_fuzzer.results
      end
    end
  end

  def stop
    if started? && !cancelled?
      @cancelled = true
      @fuzzer.close
      @bad_fuzzer.close
      @date_finished = Time.now
    end
  end

  def get_all_results
    fuzzer.results.select(&.good?) + bad_fuzzer.results
  end

  def save
    report = Command::Fuzzer::Report.new
    report.name = self.name
    report.uuid = self.uuid.to_s
    report.date_created = self.date_created
    report.date_started = self.date_started
    report.date_finished = self.date_finished
    report.results = self.get_all_results
    File.open("./reports/#{uuid.to_s}", "w+") do |file|
      file.puts report.to_json
    end
  end
end