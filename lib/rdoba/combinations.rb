#!/usr/bin/ruby
# frozen_string_literal: true

class Array
  private

  def __comby(i, size)
    s = "0#{format('%.*b', size, i)}0"
    v = { res: [], c0: 0, c1: 0, j: 0 }

    def up1(v)
      sub_j = v[:j] + v[:c1] + 1
      v[:res] << self[v[:j]...sub_j]
      v[:j] = sub_j
      v[:c1] = 0
    end

    def up0(v)
      sub_j = v[:j] + v[:c0] - 1
      self[v[:j]...sub_j].each do |x|
        v[:res] << [x]
      end
      v[:j] = sub_j
    end

    s.each_char do |c|
      if c == '1'
        v[:c1] += 1
        up0(v) if v[:c0] > 1
        v[:c0] = 0
      else
        v[:c0] += 1
        up1(v) if v[:c1] > 0
      end
    end
    up0(v) if v[:c0] > 1
    v[:res]
  end

  public

  def each_comby(*args)
    return self if self.empty? or not block_given?

    if args.include?(:backward)
      yield [self.dup]
      ((1 << (self.size - 1)) - 2).downto(0) do |i|
        c = __comby(i, self.size - 1)
        yield c
      end
    else
      0.upto((1 << (self.size - 1)) - 2) do |i|
        c = __comby(i, self.size - 1)
        yield c
      end
      yield [self.dup]
    end

    return self
  end
end
