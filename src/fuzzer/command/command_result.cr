class Command::Fuzzer
  class Result
    include JSON::Serializable

    property message : XMMessage = XMMessage.new
    @[JSON::Field(emit_null: true)]
    property reply : XMMessage? = nil
    property error : String = ""

    def initialize
    end

    def bad?
      reply.nil?
    end

    def good?
      !!reply
    end

    def had_error?
      !error.empty?
    end
  end
end
