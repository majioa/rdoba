module Rdoba::Mixin::TryObject
  def try(method, *args, default: nil)
    if self.respond_to?(method)
      self.send(method, *args)
    else
      default
    end
  end
end
