class Command::Fuzzer
  class Report
    include JSON::Serializable

    property name = ""
    property uuid = ""
    property date_created = Time.new(1970, 1, 1, 0, 0, 0)
    property date_started = Time.new(1970, 1, 1, 0, 0, 0)
    property date_finished = Time.new(1970, 1, 1, 0, 0, 0)
    property results = [] of Command::Fuzzer::Result

    def initialize()
    end
  end
end
