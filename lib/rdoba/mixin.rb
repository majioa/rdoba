#!/usr/bin/ruby -KU
#encoding:utf-8

module Rdoba
   module Mixin
      module EmptyObject
         def empty?
            false ; end ; end

      module EmptyNilClass
         def empty?
            true ; end ; end ; end

   def self.mixin options
      ( options || {} )[ :functions ].each do |value|
         case value
         when :empty
            Object.send :include, Rdoba::Mixin::EmptyObject
            NilClass.send :include, Rdoba::Mixin::EmptyNilClass
         else
            Kernel.puts STDERR, "Invalid rdoba-mixin options key: #{key.to_s}"
            end ; end ; end ; end


