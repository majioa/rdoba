# frozen_string_literal: true

module Rdoba::Mixin::TryObject
  def try(method, *args)
    if respond_to?(method)
      send(method, *args)
    end
  end
end
