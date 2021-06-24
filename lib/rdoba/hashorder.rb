#!/usr/bin/ruby
# frozen_string_literal: true

class Hash
  attr_reader :order

  class Each
    General = 0
    Pair = 1
    Key = 2
    Value = 3
  end

  private

  def each_special(spec)
    (@order | self.keys).each do |key|
      next unless self.has_key? key

      case spec
      when Hash::Each::General
        yield key, self[key]
      when Hash::Each::Pair
        yield key, self[key]
      when Hash::Each::Key
        yield key
      when Hash::Each::Value
        yield self[key]
      end
    end
  end

  public

  def order=(order)
    return nil if order.class != Array

    @order = order
  end

  def disorder
    @order = nil
    self
  end

  alias __each__ each
  alias __each_pair__ each_pair
  alias __each_key__ each_key
  alias __each_value__ each_value

  def each(&block)
    @order ? each_special(Hash::Each::General, &block) : __each__(&block)
  end

  def each_pair(&block)
    @order ? each_special(Hash::Each::Pair, &block) : __each_pair__(&block)
  end

  def each_key(&block)
    @order ? each_special(Hash::Each::Key, &block) : __each_key__(&block)
  end

  def each_value(&block)
    @order ? each_special(Hash::Each::Value, &block) : __each_value__(&block)
  end
end
