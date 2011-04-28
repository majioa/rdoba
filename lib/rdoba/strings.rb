#!/usr/bin/ruby -KU
#<Encoding:UTF-8>

require 'rdoba/chr'

class String
    FirstChar = 0
    alias :__set__ :[]=
    def []=(*args)
      index = args[0]
      str = args[args.size > 2 ? 2 : 1]
      if index.class == Fixnum
	if str.class == String
	  a = self.split(//u)
	  if str.size == 1
	    a[index] = str
	  else
	    a[index] = str.unpack('U*').map do |x| x.chr end
	    a.flatten!
	  end
	  return self.replace(a.join)
	end
      end
      __set__(*args)
    end

    def get(*args)
      index = args[0]
      index.class == Fixnum ? self.unpack('U*')[index] : self[*args]
    end

  if RUBY_VERSION < '1.9'

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

    def setbyte(*args)
      __set__(*args)
    end
  end

    def upcase_char(char)
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

    alias :__upcase__ :upcase
    def upcase(option = nil)
      if option == FirstChar
	r = self.dup
	r[0] = upcase_char(self.ord)
	r
      elsif self.match(/[Ѐ-ҁҊ-ԣꙀ-ꙧꚀꚗ]/u)
	self.unpack('U*').map do |chr| upcase_char(chr) end.join
      else; __upcase__ end
    end

    def downcase_char(char)
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

    alias :__downcase__ :downcase
    def downcase(option = nil)
      if option == FirstChar
	r = self.dup
	r[0] = downcase_char(self.ord)
	r
      elsif self.match(/[Ѐ-ҁҊ-ԣꙀ-ꙧꚀꚗ]/u)
	self.unpack('U*').map do |chr| downcase_char(chr) end.join
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
	     x > 0x487 and x < 0xa57c or
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

