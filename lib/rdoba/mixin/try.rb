# frozen_string_literal: true

module Rdoba::Mixin::TryObject
  def try(method, *args, default: nil)
    if respond_to?(method)
      send(method, *args)
    else
      default
    end
  end
end
