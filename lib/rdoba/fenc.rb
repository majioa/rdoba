#!/usr/bin/ruby -KU

class String
  def fenc
    return self unless Encoding.default_internal
    if self.frozen?
      self.dup.force_encoding(Encoding.default_internal || 'UTF-8').freeze
    else
      self.force_encoding(Encoding.default_internal || 'UTF-8')
    end
  end
end

