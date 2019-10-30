# class SingleFuzzer
#   CLEAR_SCREEN = "\e[H\e[2J"
#   def self.clear
#     puts CLEAR_SCREEN
#   end

#   def self.run
#     start = Time.now
#     xmm = XMMessage.new(message: "{}")
#     xmm.command = 0x03e0
#     results = {} of String => Array(UInt16)
#     bad_results = {} of UInt16 => Exception

#     while xmm.command < 0x1000
#       clear
#       puts "Starting #{xmm.command.to_s 16} - #{Time.now - start}"
#       puts "bad: #{bad_results.keys.size}"
          
#       results.each do |message, commands|
#         puts message
#         puts "  => #{commands}"
#       end

#       begin
#         socket = XMSocketTCP.new("192.168.1.10", 34567)
#         socket.login("admin", Dahua.digest "") 
#         socket.send_message xmm
#         xmm_reply = socket.receive_message
#         socket.close

#         unless results[xmm_reply.message]?
#           results[xmm_reply.message] = [] of UInt16
#         end

#         results[xmm_reply.message] << xmm.command
#       rescue exception : XMError::Exception
#         bad_results[xmm.command] = exception
#         if exception.is_a? XMError::SocketException
#           puts "sleeping"
#           sleep 120
#         end
#       end
#       xmm.command += 1
#     end
#   end
# end