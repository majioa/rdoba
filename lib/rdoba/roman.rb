#!/usr/bin/ruby -KU

class Numeric
   Roman = { 1 => 'I',
             4 => 'IV',
             5 => 'V',
             9 => 'IX',
             10 => 'X',
             40 => 'XL',
             50 => 'L',
             90 => 'XC',
             100 => 'C',
             400 => 'CD',
             500 => 'D',
             900 => 'CM',
             1000 => 'M' }
   RomanNumbers = Roman.keys.sort
   RomanToInteger = Roman.invert
   RomanDigits = RomanToInteger.keys.sort { |x,y| x.size < y.size ? 1 : x.size > y.size ? -1 : x <=> y }

   def to_rom
      res = ''
      num = self
      i = RomanNumbers.size - 1

      while num > 0
         if num >= RomanNumbers[ i ]
            res << Roman[ RomanNumbers[ i ] ]
            num -= RomanNumbers[ i ]
         else
            i -= 1 ;end;end
      res ;end;end

class String
   RomanRe = /(#{Numeric::RomanDigits.join("|")})/

   def rom
      numbers = upcase.scan(RomanRe).flatten.map { |x| Numeric::RomanToInteger[x] }
      numbers.sort do |x, y|
         if x < y
            raise "Invalid roman number" ;end
         0 ;end
      numbers.sum ;end;end
