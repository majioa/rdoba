require 'ostruct'

require 'rdoba/blank'

class Object
   def to_os
      OpenStruct.new(self.to_h.map {|(x, y)| [x.to_s, ([Hash, Array].include?(y.class) && y.to_os) || y] }.to_h)
   end
end

class Array
   def to_os
      OpenStruct.new(self.map.with_index {|y, x| [x.to_s, ([Hash, Array].include?(y.class) && y.to_os) || y] }.to_h)
   end
end

class Integer
   def to_sym
      to_s.to_sym
   end
end

class OpenStruct
   def merge_to other
      OpenStruct.new(other.to_h.merge(self.to_h))
   end

   def merge other
      OpenStruct.new(self.to_h.merge(other.to_h))
   end

   def map *args, &block
      res = self.class.new

      self.each_pair do |key, value|
         res[key] = block[key, value]
      end

      res
   end

   def select &block
      res = self.class.new

      self.each_pair do |key, value|
         res[key] = value if block[key, value]
      end

      res
   end

   def compact
      select { |_, value| !value.blank? }
   end

   def each *args, &block
      self.each_pair(*args, &block)
   end

   def reduce default = nil, &block
      res = default

      self.each_pair do |key, value|
         res = block[res, key, value]
      end

      res
   end

   # +deep_merge+ deeply merges the Open Struct hash structure with the +other_in+ enumerating it key by key.
   # +options+ are the options to change behaviour of the method. It allows two keys: :mode, and :dedup
   # :mode key can be :append, :prepend, or :replace, defaulting to :append, when mode is to append, it combines duplicated
   # keys' values into an array, when :prepend it prepends an other value before previously stored one unlike for :append mode,
   # when :replace it replace duplicate values with a last ones.
   # :dedup key can be true, or false. It allows to deduplicate values when appending or prepending values.
   # Examples:
   #    open_struct.deep_merge(other_open_struct)
   #    open_struct.deep_merge(other_open_struct, :prepend)
   #
   def deep_merge other_in, options_in = {}
      return self if other_in.nil? or other_in.blank?

      options = { mode: :append }.merge(options_in)

      other =
         if other_in.is_a?(OpenStruct)
            other_in.dup
         elsif other_in.is_a?(Hash)
            other_in.to_os
         else
            OpenStruct.new(nil => other_in)
         end

      self.reduce(other) do |res, key, value|
         res[key] =
            if res.table.keys.include?(key)
               case value
               when Hash, OpenStruct
                  value.deep_merge(res[key], options)
               when Array
                  value.concat([res[key]].compact.flatten(1))
               when NilClass
                  res[key]
               else
                  value_out =
                     if options[:mode] == :append
                        [res[key], value].compact.flatten(1)
                     elsif options[:mode] == :prepend
                        [value, res[key]].compact.flatten(1)
                     else
                        value
                     end

                  if value_out.is_a?(Array) && options[:dedup]
                     value_out.uniq
                  else
                     value_out
                  end
               end
            else
               value
            end

         res
      end
   end
end
