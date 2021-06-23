#!/usr/bin/ruby -KU
#coding:utf-8
# frozen_string_literal: true

class Array
  alias __dup__ dup
  def dup(opts = {})
    if (opts.class == Hash ? opts.key?(:recursive) : opts.to_s.to_sym == :recursive)
      res = []

      def sub_dup(value)
        if value.class.to_s =~ /(Hash|Array)/
          value.dup(:recursive)
        else
          begin
            value.dup
          rescue StandardError
            new = value
          end
        end
      end

      self.each do |value|
        res << sub_dup(value)
      end

      res
    elsif opts.empty?
      __dup__
    else
      raise "Unsupported option(s): #{opts.class == Hash ? opts.keys.join(', ') : opts}"
    end
  end
end

class Hash
  alias __dup__ dup
  def dup(opts = {})
    if (opts.class == Hash ? opts.key?(:recursive) : opts.to_s.to_sym == :recursive)
      res = {}

      def sub_dup(value)
        if value.class.to_s =~ /(Hash|Array)/
          value.dup(:recursive)
        else
          begin
            value.dup
          rescue StandardError
            new = value
          end
        end
      end

      self.each do |key, value|
        res[sub_dup(key)] = sub_dup(value)
      end

      res
    elsif opts.empty?
      __dup__
    else
      raise "Unsupported option(s): #{opts.class == Hash ? opts.keys.join(', ') : opts}"
    end
  end
end
