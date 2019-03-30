# Code translated from https://github.com/haicen/DahuaHashCreator/blob/master/DahuaHash.py
require "digest/md5"

module Dahua
  def self.compress(bytes : Slice(UInt8)) : Bytes
    i = 0
    j = 0
    output = Bytes.new(8, 0)

    while i < bytes.size
      output[j] = ((bytes[i].to_u32 + bytes[i+1].to_u32) % 62).to_u8
      if output[j] < 10
        output[j] += 48
      elsif output[j] < 36
        output[j] += 55

      else
        output[j] += 61
      end

      i = i+2
      j = j+1
    end
    output
  end

  def self.digest(password)
    md5_bytes = Digest::MD5.digest(password.encode("ascii"))
    compressed = compress(md5_bytes.to_slice)

    String.new(compressed)
  end
end