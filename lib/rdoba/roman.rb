#!/usr/bin/ruby -KU

class Numeric
  Roman = { 1 => 'I', 4 => 'IV', 5 => 'V', 9 => 'IX', 10 => 'X', 40 => 'XL', 50 => 'L',
      90 => 'XC', 100 => 'C', 400 => 'CD', 500 => 'D', 900 => 'CM', 1000 => 'M' }
  Romani = Roman.keys.sort

  def to_rom
    res = ''
    num = self
    i = Romani.size - 1

    while num > 0
      if num >= Romani[i]
        res << Roman[Romani[i]]
        num -= Romani[i]
      else
        i -= 1
      end
    end
    res
  end

end

class String
  def rom
    h = Numeric::Roman.reverse
    keys = h.keys.sort do |x,y| x.size < y.size ? 1 : x.size > y.size ? -1 : x <=> y end
    str = self.upcase
    res = 0
    while str and not str.empty?
    raise "Invalid roman number" if (keys.each do |key|
      if str =~ /^#{key}(.*)/
        str = $1
        res += h[key]
        break nil
      end
      end)
    end
    res
  end
end


