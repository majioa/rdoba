#!/usr/bin/ruby
# frozen_string_literal: true

require 'rdoba/common'

class Object
  def to_yml(o = {})
    level = o[:level] || 0
    res = ''
    res += '---' if level == 0
    res +=
      case self.class.to_sym
      when :Hash
        rs = ''
        keys.sort do |x, y|
          ix, iy = o[:order] ? [o[:order].index(x), o[:order].index(y)] : [nil, nil]
          (ix and iy) ? ix <=> iy : (ix ? -1 : (iy ? 1 : x <=> y))
        end.each do |key|
          value = self[key]
          rs += "\n" + (' ' * level * 2) + key.to_yml({ level: level + 1, order: o[:order] })
          rs += ': ' + value.to_yml({ level: level + 1, order: o[:order] })
        end
        (rs.empty? and '{}') or rs
      when :Array
        rs = ''
        each do |value|
          rs += "\n" + (' ' * level * 2) + '- ' + value.to_yml({ level: level + 1, order: o[:order] })
        end
        (rs.empty? and '[]') or rs
      when :Fixnum
        to_s
      when :String
        if self =~ /^["'\-:!#={}\[\]~]/ or self =~ /\s+$/ or self =~ /:\s/
          if count("'") < count('"')
            "'#{gsub("'", "\\'")}'"
          else
            "\"#{gsub('"', '\"')}\""
          end
        else
          self
        end
      when :NilClass
        ''
      else
        warn "Unsupported class #{self.class} to export to yml"
        ''
      end
    res
  end
end
