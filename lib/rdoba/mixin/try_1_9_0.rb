module Rdoba::Mixin::TryObject
   def try method, *args
      if self.respond_to?( method )
         self.send( method, *args ) ; end ; end ; end
