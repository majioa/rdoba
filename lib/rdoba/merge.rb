# encoding: utf-8

module Rdoba::Merge
  TARGET = :Hash

  def deep_merge(source, dest)
    dup = dest.dup
    source.each do |key, value|
      newvalue = dup.delete key
      case newvalue
      when Hash
        value.deep_merge newvalue
      when Array
        value |= newvalue
      when NilClass
      else
        raise
      end
    end
  end
end
