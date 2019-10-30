# class MagicReport
#   @io : IO = IO::Memory.new
#   def initialize(@io)
#   end

#   def make(start_time, results)
#     @io.puts "Command results: Started at #{start_time}"
#     @io.puts "Total time: #{Time.now - start_time}"

#     unique_replies = {} of UInt64 => String
#     result_matches = {} of UInt64 => Array(UInt16)

#     bad_results = results.select {|result| result.bad?}
#     bad_results.sort! {|a, b| a.message.magic <=> b.message.magic}

#     results = results.reject {|result| result.bad?}

#     # make a list of all unique replies
#     results.each do |result|
#       message = result.message.message
#       reply = nil
#       if result.good?
#         reply = result.reply.as(XMMessage).message
#       end

#       unless unique_replies[reply.hash]?
#         unique_replies[reply.hash] = reply.to_s
#         result_matches[reply.hash] = [] of UInt16
#       end
#       result_matches[reply.hash] << result.message.magic
#     end



#     unique_replies.each do |k, v|
#       if v.valid_encoding?
#         @io.puts v.dump
#       else
#         @io.puts "BINARY FILE #{v[0..50].dump}"
#       end
#       @io.puts "    Bytes: #{result_matches[k].map {|k| "0x#{k.to_s(16).rjust(4, '0')}"}}"
#     end
    
#     @io.puts
#     @io.puts "Bad Results"
#     bad_results.each {|bad_result| @io.puts "0x#{bad_result.message.magic.to_s(16).rjust(4, '0')} : #{bad_result.error}" }
#     @io.flush
#   end
# end