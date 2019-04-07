require "./dahua_hash"

module Brute
  def self.run(hash : String) : String
    current = "a"

    counter = 0
    success = false

    start_time = Time.now
    until success
      if Dahua.digest(current) == hash
        puts "SUCCESS!!!"
        success = true
        break
      end

      counter += 1
      current = current.succ

      if counter % 1_000_000 == 0
        puts " @ #{current} : #{Time.now - start_time}"
      elsif counter % 10_000 == 0
        print '.'
      end
    end
    end_time = Time.now

    puts "Time: #{end_time - start_time}"
    puts "Result: #{current} : #{Dahua.digest(current)}"
    current
  end
end