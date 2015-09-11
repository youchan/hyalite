module Adler32
  MOD = 65521

  class << self
    def calc(*args)
      a = 1
      b = 0
      c = 1000

      args.each do |str|
        throw ArgumentError, "Only string can be passed: #{str.inspect}:#{str.class}" unless str.is_a? String

        str.each_char do |char|
          a += char.ord
          b += a
          c -= 1
          if c <= 0
            a %= MOD
            b %= MOD
            c = 1000
          end
        end
      end
      a %= MOD
      b %= MOD
      (b << 16) | a
    end

    def checksum(*args)
      "%08x" % calc(*args)
    end
  end
end
