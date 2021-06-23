#!/usr/bin/ruby

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
        self.keys.sort do |x, y|
          ix, iy = o[:order] ? [o[:order].index(x), o[:order].index(y)] : [nil, nil]
          (ix and iy) ? ix <=> iy : (ix ? -1 : (iy ? 1 : x <=> y))
        end.each do |key|
          value = self[key]
          rs += "\n" + ' ' * level * 2 + key.to_yml({ level: level + 1, order: o[:order] })
          rs += ': ' + value.to_yml({ level: level + 1, order: o[:order] })
        end
        rs.empty? and '{}' or rs
      when :Array
        rs = ''
        self.each do |value|
          rs += "\n" + ' ' * level * 2 + '- ' + value.to_yml({ level: level + 1, order: o[:order] })
        end
        rs.empty? and '[]' or rs
      when :Fixnum
        self.to_s
      when :String
        if self =~ /^["'\-:!#={}\[\]~]/ or self =~ /\s+$/ or self =~ /:\s/
          if self.count("'") < self.count('"')
            "'#{self.gsub("'", "\\'")}'"
          else
            "\"#{self.gsub('"', '\"')}\""
          end
        else
          self
        end
      when :NilClass
        ''
      else
        $stderr.puts "Unsupported class #{self.class} to export to yml"
        ''
      end
    res
  end
end
