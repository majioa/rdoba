#!/usr/bin/ruby

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

