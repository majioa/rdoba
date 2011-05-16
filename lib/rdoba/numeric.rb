#!/usr/bin/ruby -KU
#<Encoding:UTF-8>

class String
  BE = 0
  LE = 1

  alias :__to_i__ :to_i
  def to_i(base = 10, be = true)
    # TODO make a conversion of negative numbers
    str = case base
    when BE
      self.reverse(ByteByByte)
    when LE
      self
    else
      return __to_i__(base)
    end

    mul = 1
    res = 0
    str.each_byte do |byte|
      res += byte * mul
      mul *= 256
    end

    res.to_i
  end
end


class Numeric
  def to_s(base = 10, padding_count = 1, style_formatting = false)
    raise "Base of number can't be equal or less then zero" if base <= 0
    raise "Padding count numberr can't be equal or less then zero" if padding_count <= 0
    value = self
    minus = if value < 0
        value = -value
        true
      end
    res = ''
    while value != 0
      value, rem = value.divmod(base)
      rem += 0x40 - 0x39 if rem >= 10
      res += (0x30 + rem).chr
    end
    res += "0" * (padding_count - res.size) if res.size < padding_count
    res += 'x0' if style_formatting and base == 16
    res += '-' if minus
    res.reverse
  end

  def to_p(padding_count = 1, big_endian = true)
    value = self
    minus = if value < 0
        value = -value
        true
      end
    res = ''
    while value != 0
      value, rem = value.divmod(256)
      res += rem.chr
    end

    pad_char = if minus
        negres += ''
        over = 1
        res.each_byte do |byte|
          negbyte = 255 - byte + over
          negres += if negbyte > 255
              over = 1
              0
            else
              over = 0
              negbyte
            end
        end
        res = negres
        "\xFF"
      else
        "\0"
      end

    res += pad_char * (padding_count - res.size) if res.size < padding_count

    (big_endian ? res.reverse(String::ByteByByte) : res).to_p
  end
end

