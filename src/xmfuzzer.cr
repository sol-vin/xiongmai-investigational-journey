require "crowbar"
class XMFuzzer
  @is_running = false
  @output : IO = IO::Memory.new

  def initialize(template : String, @output = STDOUT, @seed = 1234)
    @crowbar = Crowbar.new(template, seed: @seed) do |cr|
      # Type selector
      # Crowbar::Selector::Range.new(cr, (0...3)) do |s|
      #   s.weight = 0.01
      #   Crowbar::Mutator::Replacer.new(s) do |m|
      #     Crowbar::Generator::Bytes.new(m, length_limit: (4..4))
      #   end
      # end
    
      # # SessionID selector
      # Crowbar::Selector::Range.new(cr, (4...7)) do |s|
      #   s.weight = 0.01
      #   Crowbar::Mutator::Replacer.new(s) do |m|
      #     Crowbar::Generator::Bytes.new(m, length_limit: (4..4))
      #   end
      # end
    
      # # Unknown1 selector
      # Crowbar::Selector::Range.new(cr, (8...11)) do |s|
      #   s.weight = 2.0
      #   Crowbar::Mutator::Replacer.new(s) do |m|
      #     Crowbar::Generator::Bytes.new(m, length_limit: (4..4))
      #   end
      # end
    
      # # Unknown2 selector
      # Crowbar::Selector::Range.new(cr, (12...13)) do |s|
      #   s.weight = 2.0
      #   Crowbar::Mutator::Replacer.new(s) do |m|
      #     Crowbar::Generator::Bytes.new(m, length_limit: (2..2))
      #   end
      # end
    
      # # Magic selector
      # Crowbar::Selector::Range.new(cr, (14...15)) do |s|
      #   s.weight = 0.1
      #   Crowbar::Mutator::Replacer.new(s) do |m|
      #     Crowbar::Generator::Bytes.new(m, length_limit: (2..2))
      #   end
      # end
    
      # Turned off because of vulnerability in size uint32->int32
      # Size selector
      # Crowbar::Selector::Range.new(cr, (16...19)) do |s|
      #   s.weight = 0.00001
      #   Crowbar::Mutator::Replacer.new(s) do |m|
      #     Crowbar::Generator::Bytes.new(m, length_limit: (4..4))      
      #   end
      # end
    
      # Message selector
      Crowbar::Selector::Header.new(cr, 20, invert: true) do |s|
        s.weight = 10.0
        Crowbar::Mutator::Crowbar.new(s, seed: (:new_crowbar.hash%Int32::MAX).to_i32) do |cr|
          # Selects quoted strings
          Crowbar::Selector::Regex.new(cr, Crowbar::Constants::Regex::IN_QUOTES) do |s|
            s.weight = 1.0
            # Replace those strings with something else
            Crowbar::Mutator::Replacer.new(s) do |m|
              Crowbar::Generator::Wrapper.new(m, Crowbar::Generator::Decimal.new(m))
              Crowbar::Generator::Wrapper.new(m, Crowbar::Generator::Decimal.new(m, float: true))
              Crowbar::Generator::Wrapper.new(m, Crowbar::Generator::Bytes.new(m))
              Crowbar::Generator::Wrapper.new(m, Crowbar::Generator::Naughty.new(m, types: [:null, :logic, :empty]))
            end
    
            Crowbar::Mutator::Remover.new(s) do |m|
              m.weight = 0.01
            end
          end
    
          # Mess with symbols
          Crowbar::Selector::Regex.new(cr, /\W/) do |s|
            Crowbar::Mutator::Remover.new(s) do |m|
              m.weight = 0.01
            end
    
            Crowbar::Mutator::Repeater.new(s) do |m|
              m.weight = 0.01
            end
          end
        end
      end
    end
    @socket = XMSocketTCP.new("192.168.11.109", 34567)
    @socket.close
  end

  def is_running?
    @is_running
  end

  def run!
    unless is_running?
      @is_running = true
      spawn do
        counter = 0
        while is_running?
          Fiber.yield
          counter += 1
          print '.' if counter % 100 == 0
          print '\n' if counter % 10000 == 0
          xmm = XMMessage.from_s(@crowbar.next)
          begin
            @socket = XMSocketTCP.new("192.168.11.109", 34567)
            @socket.send_message xmm
            reply = @socket.receive_message
            @output.puts "Sent: "
            @output.puts xmm.to_s.inspect
            @output.puts "Got: "
            @output.puts reply.to_s.inspect
          rescue e : XMError::SocketException
            puts "SOCKET DOWN! #{e.inspect}"
            print '!'
            raise e
          rescue e : XMError::Exception
            @output.puts "Sent: #{xmm.to_s.inspect}"
            @output.puts "ERROR: #{e.inspect}" 
            print '!'
          rescue e
            @output.puts "Sent: #{xmm.to_s.inspect}"
            @output.puts "BAD ERROR: #{e.inspect}"
            print '!'
            raise e
          ensure
            @socket.close
            @output.flush
          end
        end
      end
    end
  end

  def close
    @is_running = false
  end
end