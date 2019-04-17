class MagicReport
  @io : IO = IO::Memory.new
  def initialize(@io)
  end

  def make(start_time, results, results_matches, bad_results)
    @io.puts "Command results: Started at #{start_time}"
    @io.puts "Total time: #{Time.now - start_time}"

    results.each do |k, v|
      if v.valid_encoding?
        @io.puts v.dump
      else
        @io.puts "BINARY FILE #{v[0..20].dump}"
      end
      @io.puts "    Bytes: #{results_matches[k].map {|k| "0x#{k.to_s(16).rjust(4, '0')}"}}"
    end
    
    @io.puts
    @io.puts "Bad Results"
    bad_results.each {|k, v| @io.puts "#{k.to_s(16).rjust(4, '0')} : #{v}" }
    @io.flush
  end
end