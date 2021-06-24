#!/usr/bin/ruby -KU
# frozen_string_literal: true

require 'rdoba/debug'

class Array
  def geta(index, options = {}) #TODO => [] + class Index
    dbp11 "[geta] <<< array = #{inspect}, index = #{index.inspect}, options = #{options.inspect}"
    options[:сокр] ||= @сокр

    if index.instance_of?(Array)
      return self if [[], ['']].include?(index)

      index = index.clone
      value = self[index.shift]
      (value.instance_of?(Hash) or value.instance_of?(Array)) ? value.geta(index, options) : value
    else
      geta_value(index, options)
    end
  end
end

class Hash
  protected

  def geta_value(cid, options = {})
    res =
      ((not cid) || cid.empty?) && self || self[cid] ||
        (options[:сокр] && (self[options[:сокр][cid]] || self[options[:сокр].reverse[cid]]))

    if not res and options[:try_regexp]
      keys.each do |key|
        break res = self[key] if key.rmatch(cid)

        next unless options[:сокр]

        options[:сокр].each_pair do |val1, val2|
          break res = self[key] if key.rmatch(cid.gsub(/#{val1}/, val2)) or key.rmatch(cid.gsub(/#{val2}/, val1))
        end
      end
    end

    res
  end

  public

  def geta(index, options = {}) #TODO => [] + class Index
    dbp11 "[geta] <<< hash = #{inspect}, index = #{index.inspect}, options = #{options.inspect}"
    options[:сокр] ||= @сокр

    if index.instance_of?(Array)
      return self if [[], ['']].include?(index)

      index = index.clone
      value = geta_value(index.shift, options)
      (value.instance_of?(Hash) or value.instance_of?(Array)) ? value.geta(index, options) : value
    else
      geta_value(index, options)
    end
  end

  def seta(index, value, options = {}) #TODO => [] + class Index
    dbp11 "[seta] <<< index: #{index.inspect}, value: #{value.inspect}, options: #{options.inspect}"
    options[:сокр] ||= @сокр

    return self[index] = value if index.class != Array # TODO spec index

    back = 0
    index =
      index.reverse.map do |x|
        if x.empty?
          back += 1
          nil
        elsif back > 0
          back -= 1
          nil
        else
          x
        end
      end.compact.reverse
    dbp12 "[seta]> result index: #{index.inspect}"

    obj = nil
    o = self
    dbp14 "[seta]>> self: #{o.inspect}"
    set_idx = index.pop
    par_class = set_idx =~ /^\d+$/ ? Array : Hash
    par_idx = nil
    index.each do |idx|
      unless o
        dbp14 "[seta]>> parent idx: #{par_idx.inspect}, idx: #{idx.inspect}, parent obj: #{o.inspect}"
        o = idx =~ /^\d+$/ && [] || {}
        obj[par_idx] = o
      end
      obj = o
      o = obj.instance_of?(Hash) ? obj.geta_value(idx, options) : obj[idx]
      dbp14 "[seta]>> cur idx: #{idx.inspect}, parent obj: #{obj.inspect}, obj: #{o.inspect}"
      unless o
        if idx == index.last
          o = par_class.new
          obj[idx] = o
        else
          par_idx = idx =~ /^\d+$/ && idx.to_i || idx
        end
      end
    end

    raise 'Invalid path' unless o # TODO special exception

    o[set_idx] = value
  end
end
