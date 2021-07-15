#!/usr/bin/ruby -KU
# frozen_string_literal: true

class Object
  def xor(val1)
    val0 = !!self
    (val0 and !val1) or (!val0 and val1)
  end

  # calls any method
  def co(method, *_args)
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
        opt.each do |x, y|
          v[x] = y
        end
      when :Array
        opt.each do |x|
          v[x] = true
        end
      when :Symbol
        v[opt] = true
      end
    end
    v
  end

  def apply_opts(opts)
    parse_opts(opts).each do |x, y| instance_variable_set("@#{x}".to_sym, y)end
  end
end

class NilClass
  def =~(value)
    value.nil?
  end

  def +(other)
    other
  end

  def <<(value)
    [value]
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

  def <=>(other)
    -1
  end
end

class Array
  def purge
    compact.delete_if { |x| x.empty? }
  end

  def >>(value = nil)
    value ? delete(value) : shift
  end

  alias __get__ []
  def [](index, *args)
    return __get__(index.to_i, *args) if index.instance_of?(String) and index =~ /^\d+$/

    __get__(index, *args)
  end

  alias __set__ []=
  def []=(index, value, *args)
    return __set__(index.to_i, value, *args) if index.instance_of?(String) and index =~ /^\d+$/

    __set__(index, value, *args)
  end
end

class String
  def -(other)
    # TODO: make smart search for match in the 'str', when only last subpart matched to 'self'
    len = size
    bc = ec = nil
    (0...len).each do |idx|
      break bc = idx if self[idx] == other[0]
    end
    ((bc + 1)...len).each do |idx| break ec = idx if self[idx] != other[idx - bc]end if bc
    bc ? ec ? self[0, bc] + self[ec, len - ec] : self[0, bc] : clone
  end

  alias __match__ =~
  def =~(value)
    if value.instance_of?(String)
      self == value
    elsif value.instance_of?(Regexp)
      value =~ self
    else
      __match__(value)
    end
  end

  def rmatch(value)
    self == value || self =~ %r{^/([^/]+)} && value =~ /#{Regexp.last_match(1)}/
  end

  def hexdump
    res = ''
    i = 0
    each_byte do |byte|
      res << format('%.2X ', byte)
      i += 1
      res << "\n" if i % 16 == 0
    end
    res
  end
end

class Hash
  def |(other)
    res = dup
    other.each_pair do |key, val|
      if val.instance_of?(res[key].class)
        if val.instance_of?(Hash)
          res[key] |= other[key]
        elsif val.instance_of?(Array)
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
    each_pair do |key, value|
      if h.key? value
        if h[value].instance_of?(Array)
          h[value] << key
        else
          h[value] = [h[value], key]
        end
      else
        h[value] = key
      end
    end
    h
  end
end
