#!/usr/bin/ruby -KU
# frozen_string_literal: true

require 'rdoba/common'
require 'rdoba/strings'

class String
  alias _rdoba_to_i to_i
  def to_i(base = 10, *opts)
    v = parse_opts(opts)
    if v[:be]
      str, sign, num = (self.match /\s*(-?)([0-9a-fx]+)/u).to_a
      if str
        n = num.reverse._rdoba_to_i(base)
        sign.empty? && n || -n
      else
        0
      end
    else
      _rdoba_to_i(base)
    end
  end
end

class Integer
  alias _rdoba_to_s to_s
  def to_s(base = 10, *opts)
    v = parse_opts(opts)

    return _rdoba_to_s(base) unless v[:padding] or v[:style_formatting]

    raise "Base of number can't be equal or less then zero" if base <= 0
    raise "Padding count numberr can't be equal or less then zero" if v[:padding] <= 0

    value = self
    minus =
      if value < 0
        value = -value
        true
      end
    res = ''
    while value != 0
      value, rem = value.divmod(base)
      rem += 0x40 - 0x39 if rem >= 10
      res += (0x30 + rem).chr
    end
    res += '0' * (v[:padding].to_i - res.size) if res.size < v[:padding].to_i
    res += 'x0' if v[:style_formatting] and base == 16
    res += '-' if minus
    res.reverse
  end
end

class Numeric
  def to_p(*opts)
    v = parse_opts(opts)

    value = self
    minus =
      if value < 0
        value = -value
        true
      end
    res = ''
    while value != 0
      value, rem = value.divmod(256)
      res += rem.chr
    end

    pad_char =
      if minus
        negres += ''
        over = 1
        res.each_byte do |byte|
          negbyte = 255 - byte + over
          negres +=
            if negbyte > 255
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

    res += pad_char * (v[:padding].to_i - res.size) if res.size < v[:padding].to_i

    plain = (v[:be] ? res.reverse(String::ByteByByte) : res).to_p
    plain
  end
end
