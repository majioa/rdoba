#!/usr/bin/ruby -KU
# frozen_string_literal: true

class String
  # TODO: obsolete
  ByteByByte = 0
  FirstChar = 1
end

module Rdoba
  module Mixin
    class InvalidOption < StandardError
    end

    module CompareString
      def compare_to(value, opts = {})
        if opts == :ignore_diacritics || (opts.instance_of?(Hash) && opts.key?(:ignore_diacritics))
          # TODO: verify composite range
          def crop_diacritics(x)
            ((x < 0x300 || (x > 0x36f && x < 0x483) || (x > 0x487 && x < 0xa67c) || x > 0xa67d) && x) || nil
          end

          (unpack('U*').map do |x| crop_diacritics(x)end.compact) <=>
            (value.unpack('U*').map do |x| crop_diacritics(x)end.compact)
        else
          self <=> value
        end
      end
    end

    module ReverseString
      Fixups = [:reverse]

      Aliases = { __rdoba_mixin_reverse_orig__: :reverse }

      def __rdoba_mixin_reverse__(step = 1)
        if (!step.is_a?(Numeric) || step < 0) && step != :byte_by_byte
          raise "Invalid step value #{step.inspect}"
        end

        if [:byte_by_byte, String::ByteByByte].include?(step)
          arr = []
          each_byte do |byte|
            arr << byte.chr
          end
          arr.reverse.join.force_encoding(encoding)
        elsif step == 1
          __rdoba_mixin_reverse_orig__
        elsif step > 1
          res = ''
          offset = ((size + 1) / step * step) - step
          (0..offset).step(step) do |shift|
            res += self[offset - shift..offset - shift + 1]
          end
          res
        end
      end
    end

    module CaseString
      Fixups = %i[upcase downcase]

      Aliases = { __rdoba_mixin_upcase_orig__: :upcase, __rdoba_mixin_downcase_orig__: :downcase }

      ConvertTable = {
        up: {
          ranges: [
            { ords: [(0xE0..0xFF), (0x3B1..0x3CB), (0x430..0x44F)], change: proc { |chr, _value| chr -= 0x20 } },
            { ords: [(0x3AC..0x3AC)], change: proc { |ord| ord -= 0x26 } },
            { ords: [(0x3AD..0x3AF)], change: proc { |ord| ord -= 0x25 } },
            { ords: [(0x3B0..0x3B0)], change: proc { |ord| ord -= 0x22 } },
            {
              ords: [
                (0x1F00..0x1F07),
                (0x1F10..0x1F17),
                (0x1F20..0x1F27),
                (0x1F30..0x1F37),
                (0x1F40..0x1F47),
                (0x1F50..0x1F57),
                (0x1F60..0x1F67),
                (0x1F80..0x1F87),
                (0x1F90..0x1F97),
                (0x1Fa0..0x1Fa7),
                (0x1Fb0..0x1Fb3)
              ],
              change: proc { |ord| ord += 0x8 }
            },
            { ords: [(0x450..0x45F)], change: proc { |ord| ord -= 0x50 } },
            {
              ords: [
                (0x100..0x1B9),
                (0x1C4..0x233),
                (0x460..0x481),
                (0x48A..0x523),
                (0x1E00..0x1E95),
                (0x1EA0..0x1EFF),
                (0x0A642..0xA667),
                (0x0A680..0x0A697),
                (0xA722..0xA7A9)
              ],
              change: proc { |ord| (ord.odd? && (ord - 1)) || ord }
            }
          ],
          default:
            proc do |ord|
              [ord].pack('U').__rdoba_mixin_upcase_orig__
            end
        },
        down: {
          ranges: [
            { ords: [(0xC0..0xDF), (0x391..0x3AB), (0x410..0x42F)], change: proc { |chr, _value| chr += 0x20 } },
            { ords: [(0x386..0x386)], change: proc { |ord| ord += 0x26 } },
            { ords: [(0x388..0x38A)], change: proc { |ord| ord += 0x25 } },
            { ords: [(0x38E..0x38E)], change: proc { |ord| ord += 0x22 } },
            {
              ords: [
                (0x1F08..0x1F0F),
                (0x1F18..0x1F1F),
                (0x1F28..0x1F2F),
                (0x1F38..0x1F3F),
                (0x1F48..0x1F4F),
                (0x1F58..0x1F5F),
                (0x1F68..0x1F6F),
                (0x1F88..0x1F8F),
                (0x1F98..0x1F9F),
                (0x1Fa8..0x1FaF),
                (0x1Fb8..0x1FbA)
              ],
              change: proc { |ord| ord -= 0x8 }
            },
            { ords: [(0x400..0x40F)], change: proc { |ord| ord += 0x50 } },
            {
              ords: [
                (0x100..0x1B9),
                (0x1C4..0x233),
                (0x450..0x481),
                (0x48A..0x523),
                (0x1E00..0x1E95),
                (0x1EA0..0x1EFF),
                (0x0A642..0xA667),
                (0x0A680..0x0A697),
                (0xA722..0xA7A9)
              ],
              change: proc { |ord| (ord.even? && (ord + 1)) || ord }
            }
          ],
          default:
            proc do |ord|
              [ord].pack('U').__rdoba_mixin_downcase_orig__
            end
        }
      }

      def self.change_case_char(dest, char)
        ord = char.is_a?(String) ? char.ord : char.to_i
        table = ConvertTable[dest]
        nord =
          table[:ranges].each do |range|
            c =
              range[:ords].each do |r|
                if r.include?(ord)
                  break false
                end
              end
            unless c
              break range[:change].call ord
            end
          end

        unless nord.is_a? Numeric
          return table[:default].call ord
        end

        [nord].pack('U')
      end

      def self.up_char(char)
        CaseString.change_case_char :up, char
      end

      def self.downcase_char(char)
        CaseString.change_case_char :down, char
      end

      if RUBY_VERSION < '1.9'
        alias setbyte []=

        def encoding
          'UTF-8'
        end

        def force_encoding(*_args)
          self
        end

        def ord
          a = nil
          each_byte do |b|
            case (b & 0xC0)
            when 0xc0
              a = (b & 0x3F)
            when 0x80
              return (a << 6) + (b & 0x3F)
            else
              return b
            end
          end
        end
      end

      def __rdoba_mixin_downcase__(options = {})
        __rdoba_mixin_changecase__ :down, options
      end

      def __rdoba_mixin_upcase__(options = {})
        __rdoba_mixin_changecase__ :up, options
      end

      def __rdoba_mixin_changecase__(reg, options = {})
        unless %i[up down].include? reg
          return self
        end

        re = Regexp.new '[\x80-\xFF]', nil, 'n'
        if options == String::FirstChar || options.include?(:first_char)
          r = dup
          r[0] = CaseString.change_case_char reg, ord
          r
        elsif dup.force_encoding('ASCII-8BIT').match re
          unpack('U*').map do |chr|
            CaseString.change_case_char reg, chr
          end.join
        elsif reg == :up
          __rdoba_mixin_upcase_orig__
        else
          __rdoba_mixin_downcase_orig__
        end
      end
    end

    module To_hArray
      def to_h(options = {})
        h = {}
        each do |v|
          if v.is_a? Array
            if h.key? v[0]
              unless h[v[0]].is_a? Array
                h[v[0]] = [h[v[0]]]
              end

              if v.size > 2
                h[v[0]].concat v[1..-1]
              else
                h[v[0]] << v[1]
              end
            else
              h[v[0]] = (v.size > 2 && v[1..-1]) || v[1]
            end
          elsif h.key? v
            unless h[v].is_a? Array
              h[v] = [h[v]]
            end

            h[v] << v
          else
            h[v] = nil
          end
        end

        if options[:save_unique]
          h.each_pair do |_k, v|
            if v.is_a? Array
              v.uniq!
            end
          end
        end

        h
      end
    end

    module Split_byArray
      #
      # +split_by+ method splits the +self+ array by a condition,
      # which is evaliated in a passed block, in two versions that are
      # the return value. Usage:
      #
      # require 'rdoba'
      #
      # rdoba mixin: :split_by
      #
      # (first, second) = [0,1,2,3].split_by { |value| value % 2 == 0 }
      # first # => [0,2]
      # second # => [1,3]
      #
      def split_by
        idxs = []
        rejected = reject.with_index do |v, i| yield(v) && (idxs << i)end
        [values_at(*idxs), rejected]
      end
    end

    module EmptyObject
      def empty?
        false
      end
    end

    module EmptyNilClass
      def empty?
        true
      end
    end
  end
end

if RUBY_VERSION >= '2.0.0'
  require_relative 'mixin/try'
else
  require_relative 'mixin/try_1_9_0'
end

require_relative 'mixin/wait_if'

module Rdoba
  def self.mixin(options)
    [options[:value]].flatten.each do |value|
      case value
      when :case
        Mixin::CaseString::Aliases.each do |k, v|
          ::String.send :alias_method, k, v
        end
        Mixin::CaseString::Fixups.each do |e|
          ::String.class_eval "def #{e}(*args);self.__rdoba_mixin_#{e}__(*args);end", __FILE__, __LINE__
        end
        ::String.include Mixin::CaseString
      when :reverse
        Mixin::ReverseString::Aliases.each do |k, v|
          ::String.send :alias_method, k, v
        end
        Mixin::ReverseString::Fixups.each do |e|
          ::String.class_eval "def #{e}(*args);self.__rdoba_mixin_#{e}__(*args);end", __FILE__, __LINE__
        end
        String.include Mixin::ReverseString
      when :compare
        String.include Mixin::CompareString
      when :to_h
        if [].respond_to?(:to_h)
          m = Mixin::To_hArray.instance_method(:to_h)
          Array.send(:define_method, :to_h, m)
        else
          Array.include Mixin::To_hArray
        end
      when :time
        require_relative 'mixin/time'
        if File.respond_to?(:mtime)
          %i[mtime atime ctime].each do |name|
            m = Mixin::Time.instance_method(name)
            ::File.send(:define_singleton_method, name, m)
          end
        else
          ::File.extend Mixin::Time
        end
      when :wait_if
        Object.include Mixin::Wait_ifKernel
      when :split_by
        Array.include Mixin::Split_byArray
      when :try
        Object.include Mixin::TryObject
      when :empty
        Object.include Mixin::EmptyObject
        NilClass.include Mixin::EmptyNilClass
      else
        raise(Mixin::InvalidOption, 'Invalid rdoba-mixin options key: ' + value.to_s)
      end
    end
  end
end
