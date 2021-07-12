#!/usr/bin/ruby -KU
# frozen_string_literal: true

require 'strscan'
require 'rdoba/re'
require 'rdoba/roman'
require 'rdoba/numeric'

module Kernel
  alias __sprintf__ sprintf
  def sprintf(format, *args)
    nargs = []
    nformat = ''

    fmt = format.split('%')
    nformat = fmt.shift

    until fmt.empty?
      part = fmt.shift
      part ||= '%' + fmt.shift
      if part =~ /([0-9 #+\-*.]*)([bcdEefGgiopsuXxP])(.*)/ and Regexp.last_match(2) == 'P'
        keys = Regexp.last_match(1) || ''
        str = Regexp.last_match(3) || ''
        if keys =~ /(-)?([0-9*]*)\.?([0-9*]*)(\+?)/
          value = args.shift
          indent = ' ' * (Regexp.last_match(2) == '*' ? args.shift : Regexp.last_match(2)).to_i
          plain =
            value &&
              value.to_p(
                padding:
                  (Regexp.last_match(3) == '*' ? args.shift : Regexp.last_match(3).empty? ? 1 : Regexp.last_match(3))
                    .to_i,
                be: Regexp.last_match(4).empty? ? nil : true
              ) || ''
          nformat += (Regexp.last_match(1) ? plain + indent : indent + plain) + str
        else
          nformat += '%' + keys + 'c' + str
          nargs.push args.shift
        end
      else
        nformat += '%' + part
        l = Regexp.last_match(1) =~ /\*/ ? 2 : 1
        while l > 0
          nargs.push args.shift
          l -= 1
        end
      end
    end
    __sprintf__(nformat, *nargs).to_p
  end
end

class String
  def scanf_re(format)
    fss = StringScanner.new(format) # TODO remove scanner in favor of match
    nformat = ''

    pos = 0
    argfs = []
    while fss.scan_until(/%([0-9 #+\-*]*)(?:\.([0-9]+)(\+)?)?([bcdefgiosuxr])/)
      argfs << [fss[1], fss[2], fss[3], fss[4]]

      # TODO add performing the special case in fss[1]
      nformat +=
        fss.pre_match[pos..-1].to_res +
          case fss[4]
          when 'x'
            '(?:0[xX])?([a-fA-F0-9]+)'
          when 'i'
            '([+\-]?[0-9]+)'
          when 'u'
            '([0-9]+)'
          when 'e'
            '([+\-]?[0-9]+[eE][+\-]?[0-9]+)'
          when 'f'
            '([+\-]?[0-9]+\.[0-9]*)'
          when 'g'
            '([+\-]?[0-9]+(?:[eE][+\-]?[0-9]+|\.[0-9]*))'
          when 'c'
            fss[2] ? "(.{1,#{fss[2]}})" : '(.)'
          when 'b'
            '([01]+)b?'
          when 'o'
            '0([0-9]+)'
          when 'd'
            '([+\-]?(?:0X)?[A-F0-9.+]+)'
          when 's'
            '(.+)'
          when 'r'
            '([IVXLCDMivxlcdm]+)'
          end

      pos = fss.pos
    end

    nformat += fss.rest

    [/#{nformat}/, argfs]
  end

  (alias __scanf__ scanf) if instance_methods(false).include?(:scanf)
  def scanf(format, &block)
    re, argfs = scanf_re(format)

    ss = StringScanner.new(self)
    res = []
    rline = []
    while ss.scan_until(re)
      argfs.each_index do |i|
        argf = argfs[i]
        value = ss[i + 1]
        rline <<
          case argf[3]
          when 'x'
            value.to_i(16)
          when /[diu]/
            value.to_i
          when /[efg]/
            value.to_f
          when 'c'
            argf[2] ? value.to_i(:be) : value.to_i
          when 'b'
            value.to_i(2)
          when 'o'
            value.to_i(8)
          when 's'
            value
          when 'r'
            value.rom
          end
      end

      if block
        pass = []
        (1..block.arity).each do |i|
          pass << "rline[#{i}]"
        end
        eval "yield(#{pass.join(', ')})"
      end

      res << rline
    end

    res
  end

  def consolize
    ss = StringScanner.new(self)
    res = ''
    ostr = ''
    pos = 0

    while ss.scan_until(/\r/)
      ostr[0...ss.pre_match.size - pos] = ss.pre_match[pos..-1]
      pos = ss.pos

      next unless ss.post_match[0] == "\n"[0]

      res = ostr
      pos += 1
      ostr = ''
    end

    ostr[0...ss.rest.size] = ss.rest
    res + ostr
  end
end
