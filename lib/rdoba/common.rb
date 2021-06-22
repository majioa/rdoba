#!/usr/bin/ruby -KU
#coding:utf-8

class Object
  def xor(val1)
    val0 = (not not self)
    ((val0) and (not val1)) or ((not val0) and (val1))
  end

  def co(method, *args) #calls any method
    eval "#{method}(*args)"
  end

  def to_sym
    to_s.to_sym
  end

  def parse_opts(opts)
    v = {}
    opts.each do |opt|
      case opt.class.to_s.to_sym
      when :Hash
	opt.each do |x,y| v[x] = y end
      when :Array
	opt.each do |x| v[x] = true end
      when :Symbol
	v[opt] = true
      end
    end
    v
  end

  def apply_opts(opts)
    parse_opts(opts).each do |x,y|
      self.instance_variable_set("@#{x}".to_sym, y)
    end
  end
end

class NilClass
  def =~(value)
    value == nil
  end

  def +(value)
    value
  end

  def <<(value)
    [ value ]
  end

  def empty?
    true
  end

  def to_i
    0
  end
  alias ord to_i

  def size
    0
  end

  def <=>(value)
    -1
  end
end


class Array
  def purge
    self.compact.delete_if {|x| x.empty? }
  end

  def >>(value = nil)
    value ? delete(value) : shift
  end

  alias __get__ []
  def [](index, *args)
    return __get__(index.to_i, *args) if index.class == String and index =~ /^\d+$/
    __get__(index, *args)
  end

  alias __set__ []=
  def []=(index, value, *args)
    return __set__(index.to_i, value, *args) if index.class == String and index =~ /^\d+$/
    __set__(index, value, *args)
  end
end

class String
  def -(str)
    #TODO make smart search for match in the 'str', when only last subpart matched to 'self'
    len = self.size
    bc = ec = nil
    (0...len).each do |idx|
      break bc = idx if self[idx] == str[0]
    end
    ((bc + 1)...len).each do |idx|
      break ec = idx if self[idx] != str[idx - bc]
    end if bc
    (not bc) ? self.clone : (not ec) ? self[0, bc] : self[0, bc] + self[ec, len - ec]
  end

  alias __match__ =~
  def =~(value)
    if value.class == String
      self == value
    elsif value.class == Regexp
      value =~ self
    else
      __match__(value)
    end
  end

  def rmatch(value)
    self == value || self =~ /^\/([^\/]+)/ && value =~ /#{$1}/
  end

  def hexdump
    res= ''
    i = 0
    self.each_byte do |byte|
      res << sprintf("%.2X ", byte)
      i += 1
      res << "\n" if i % 16 == 0
    end
    res
  end
end

class Hash
  def |(inval)
    res = self.dup
    inval.each_pair do |key, val|
      if val.class == res[key].class
        if val.class == Hash
          res[key] |= inval[key]
        elsif val.class == Array
          res[key].concat val
        else
          res[key] = val
        end
      else
        res[key] = val
      end
    end
    res
  end

  def reverse!
    replace(reverse)
  end

  def reverse
    h = {}
    self.each_pair do |key, value|
      if h.key? value
	if h[value].class == Array
	  h[value] << key
	else
	  h[value] = [ h[value], key ]
	end
      else
	h[value] = key
      end
    end
    h
  end
end


