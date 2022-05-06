class Object
   def blank?
      case self
      when NilClass, FalseClass
         true
      when TrueClass
         false
      when Hash, Array
         !self.any?
      else
         self.to_s == ""
      end
   end
end
