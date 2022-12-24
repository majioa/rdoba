# vim:setl sw=3 sts=3 ts=3 et:
# encoding: utf-8

module Rdoba::Merge
   TARGET = :Hash

   def deep_merge other
      return self if other.nil? or other == {}

      other_hash = other.is_a?(Hash) && other || { nil => other }
      common_keys = self.keys & other_hash.keys
      base_hash = (other_hash.keys - common_keys).reduce({}) do |res, key|
         res[key] = other_hash[key]
         res
      end

      self.reduce(base_hash) do |res, (key, value)|
         new =
         if common_keys.include?(key)
            case value
            when Hash
               value.deep_merge(other_hash[key])
            when Array
               value.concat([ other_hash[key] ].compact.flatten(1))
            when NilClass
               other_hash[key]
            else
               [ value, other_hash[key] ].compact.flatten(1)
            end
         else
            value
         end

         res[key] = new
         res
      end
   end
end
