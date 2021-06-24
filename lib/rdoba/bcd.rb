#encoding: utf-8
# frozen_string_literal: true


module BCD
  class ParseError < RuntimeError
    def initialize(msg = 'Invalid positive integer value'); end
  end

  class ConvertError < RuntimeError
    def initialize(msg = 'Invalid number has given'); end
  end

  def to_i
    res = 0
    mul = 1
    each_byte do |c|
      def pow(value, mul)
        if value >= 10
          raise ConvertError
        end

        value * mul
      end
      res += pow(c.ord & 0xF, mul)
      mul *= 10
      res += pow(c.ord >> 4, mul)
      mul *= 10
    end
    res
  end

  def self.parse(value)
    if value < 0
      raise ParseError
    end

    res = BCDString.new
    if res.respond_to? :force_encoding
      res.force_encoding('ASCII-8BIT')
    end
    if value > 0
      part = nil
      while value > 0
        value, mod = value.divmod 10
        if part
          res << ((mod << 4) | part).chr
          part = nil
        else
          part = mod
        end
      end
      if part
        res << part.chr
      end
    else
      res << 0.chr
    end
    res
  end
end

class BCDString < String
  include BCD

  def initialize(value = nil)
    if value.is_a? Numeric
      replace BCD.parse(value)
    else
      super value.to_s
    end
  end
end

class Numeric
  def to_bcd
    # NOTE: return as plain LSB string
    BCD.parse value
  end
end
