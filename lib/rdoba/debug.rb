#!/usr/bin/ruby

class Object
  attr_reader :debug

  @debug = nil
  eval "$debug_#{self.class} = 0"

public

  def debug=(level)
    @debug = level
  end

  def dbc(level)
    level = level.to_i
    if level > 0
      clevel = @debug || begin; eval "$debug_#{self.class}"; rescue; nil; end
      clevel ? (clevel.to_i & level) == level : false
    else
      false
    end
  end

  def dbp(level, text)
    Kernel.puts text if dbc(level)
  end

  def dbg(level, code, vars = {})
    if dbc(level)
      if vars
        vars.each_pair do |var, value|
          instance_variable_set(var, value)
        end
      end
      eval code
    end
  end

  (1..0xF).each do |x|
    (1..0xF).each do |y|
      idx = sprintf "%x%x", x, y
      eval "def dbp#{idx}(text); dbp(0x#{idx},text); end"
      eval "def dbg#{idx}(text); dbg(0x#{idx},text); end"
    end
  end
end

