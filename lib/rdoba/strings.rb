#!/usr/bin/ruby -KU
#<Encoding:UTF-8>

class String

  def self.upcase(char)
      chr = char.class == String ? char.ord : char.to_i
      if chr >= 0x430 and chr < 0x450
        chr -= 0x20
      elsif chr >= 0x410 and chr < 0x430
      elsif chr >= 0x400 and chr < 0x410 or
          chr >= 0x450 and chr < 0x482 or
          chr >= 0x48A and chr < 0x524 or
          chr >= 0xA642 and chr < 0xA668 or
          chr >= 0xA680 and chr < 0xA698
        chr -= 1 if (chr % 1) == 1
      else
        return chr.chr.__upcase__
      end
      chr.chr
  end

  def self.downcase(char)
      chr = (char.class == String) ? char.ord : char.to_i
      if chr >= 0x410 and chr < 0x430
        chr += 0x20
      elsif chr >= 0x430 and chr < 0x450
      elsif chr >= 0x400 and chr < 0x410 or
          chr >= 0x450 and chr < 0x482 or
          chr >= 0x48A and chr < 0x524 or
          chr >= 0xA642 and chr < 0xA668 or
          chr >= 0xA680 and chr < 0xA698
        chr += 1 if (chr % 1) == 0
      else
        return chr.chr.__downcase__
      end
      chr.chr
  end

  if RUBY_VERSION < '1.9'

    alias :setbyte :[]=

    def encoding
      'UTF-8'
    end

    def force_encoding(*args)
      self
    end

    def ord
      a = nil
      self.each_byte do |b|
	c = b & 0xC0
	case c
	when 0xc0
	  a = (b & 0x3F)
	when 0x80
	  return (a << 6) + (b & 0x3F)
	else
	  return b
	end
      end
    end

  end

  FirstChar = 0
  alias :__upcase__ :upcase
  def upcase(option = nil)
    if option == FirstChar
      r = self.dup
      r[0] = String.upcase(self.ord)
      r
    elsif self.match(/[Ѐ-ҁҊ-ԣꙀ-ꙧꚀꚗ]/u)
      self.unpack('U*').map do |chr| String.upcase(chr) end.join
    else; __upcase__ end
  end

  alias :__downcase__ :downcase
  def downcase(option = nil)
    if option == FirstChar
      r = self.dup
      r[0] = String.downcase(self.ord)
      r
    elsif self.match(/[Ѐ-ҁҊ-ԣꙀ-ꙧꚀꚗ]/u)
      self.unpack('U*').map do |chr| String.downcase(chr) end.join
    else; __downcase__ end
  end

  alias :to_p :to_s

  ByteByByte = 0
  alias :__reverse__ :reverse
  def reverse(step = 1)
      case step
      when ByteByByte
          arr = []
          self.each_byte do |byte| arr << byte.chr end
          arr.reverse.join
      when 1
          __reverse__
      else
          res = ''
          offset = (self.size + 1) / step * step - step
          (0..offset).step(step) do |shift|
              res += self[offset - shift..offset - shift + 1]
          end
          res
      end
  end

  def compare_to(value, opts = {} )
    if opts == :ignore_diacritics or
      (opts.class == Hash and opts.key? :ignore_diacritics)
      # TODO verify composite range
      def crop_diacritics(x)
        (x < 0x300 or
           x > 0x36f and x < 0x483 or
           x > 0x487 and x < 0xa67c or
           x > 0xa67d) && x || nil
      end

      (self.unpack('U*').map do |x| crop_diacritics(x)
      end.compact) <=> (value.unpack('U*').map do |x| crop_diacritics(x)
      end.compact)
    else
      self <=> value
    end
  end
end

class Fixnum
  alias :__chr__ :chr
  def chr
    if self >= 256
      num = self; s = "\0"; byte = 0x80; a = []
      while num >= 0x40
	s.setbyte(0, byte + (num & 0x3F))
	a << s.dup; num >>= 6; byte = 0x40
      end
      s.setbyte(0, 0xC0 + (num & 0x3F))
      a << s
      a.reverse.join.force_encoding('UTF-8')
    else; __chr__ end
  end
end

