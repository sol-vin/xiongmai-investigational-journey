class Command::Fuzzer
  class Result
    property message : XMMessage = XMMessage.new
    property reply : XMMessage? = nil
    property error : String = ""

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
