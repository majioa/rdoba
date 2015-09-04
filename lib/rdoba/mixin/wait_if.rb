require 'timeout'

module Rdoba::Mixin::Wait_ifKernel

   ##
   # +wait_if+ waits for +timeout+ second to the condition passed via block,
   # and in case if it failed, returns false, otherwise true. +timeout+ can
   # be a float or integer number of seconds, but if passed 0 or nil it waits
   # forever. Default value is 6 seconds. Example:
   #
   #     wait_if(5) { sleep 2; true } # => true
   #     wait_if(5) { sleep 10; true } # => false
   # 
   def wait_if timeout = 6
      begin
         Timeout::timeout( timeout ) do
            until yield() do
               sleep( 0.1 ) ; end ; end
         true
      rescue Timeout::Error
         false ; end ; end ; end
