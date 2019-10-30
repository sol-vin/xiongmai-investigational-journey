# class XMMagicFuzzer
#   def self.run
#     command_names = File.read("./rsrc/lists/list_of_commands.txt").split("\n")
#     command_names.each do |command_name|
#       unless command_name.split("")[0] == "#"
#         File.open("./logs/temp/#{command_name.downcase}.log", "w+") do |file|
#           xmm = XMMessage.new
#           xmm.message = JSON.build do |json|
#             json.object do
#               json.field "Name", "#{command_name}"
#               json.field "SessionID", "0x00000000"
#             end
#           end
#           m = MagicFuzzer.new(
#             magic: (0x0000..0x1000),
#             username: "admin",
#             password: "password",
#             output: file,
#             template: xmm
#           )
#           m.run
#           m.wait_until_done
#           m.report
#           m.close
#         end
#       end
#     end
#   end
# end
