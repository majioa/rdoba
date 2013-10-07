#coding: utf-8
module Rdoba
   module Slovo
      Methods = {
         :each => {
            :name    => :еже,
            :applyto => [ ::Array, ::ENV, ::ARGF, ::Dir, ::Enumerator, ::Hash,
                          ::IO, ::Range, ::Struct ]
            } } ; end
   def self.slovo options = {}
      Slovo::Methods.each do |m, v|
         v[ :applyto ].each do |c|
            if c.methods.include? m
               c.send :instance_eval, "alias :#{v[ :name ]} :#{m}" ; end
            if c.methods.include?( :instance_methods ) &&
                  c.instance_methods.include?( m )
               c.send :class_eval, "alias :#{v[ :name ]} :#{m}" ; end
               end ; end ; end ; end
