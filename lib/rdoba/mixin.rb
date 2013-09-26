#!/usr/bin/ruby -KU
#encoding:utf-8

module Rdoba
   module Mixin
      module To_hArray
         def to_h options = {}
            h = {}
            self.each do |v|
               if v.is_a? Array
                  if h.key? v[ 0 ]
                     if !h[ v[ 0 ] ].is_a? Array
                        h[ v[ 0 ] ] = [ h[ v[ 0 ] ] ] ; end

                     if v.size > 2
                        h[ v [ 0 ] ].concat v[ 1..-1 ]
                     else
                        h[ v [ 0 ] ] << v[ 1 ] ; end
                  else
                     h[ v[ 0 ] ] = v.size > 2 && v[ 1..-1] || v[ 1 ] ; end
               else
                  if h.key? v
                     if !h[ v ].is_a? Array
                        h[ v ] = [ h[ v ] ] ; end

                     h[ v ] << v
                  else
                     h[ v ] = nil ; end ; end ; end

            if options[ :save_unique ]
               h.each_pair do |k,v|
                  if v.is_a? Array
                     v.uniq! ; end ; end ; end

            h ; end ; end

      module EmptyObject
         def empty?
            false ; end ; end

      module EmptyNilClass
         def empty?
            true ; end ; end ; end

   def self.mixin options
      ( options || [] ).each do |value|
         case value
         when :to_h
            Array.send :include, Rdoba::Mixin::To_hArray
         when :empty
            Object.send :include, Rdoba::Mixin::EmptyObject
            NilClass.send :include, Rdoba::Mixin::EmptyNilClass
         else
            Kernel.puts STDERR, "Invalid rdoba-mixin options key: #{value.to_s}"
            end ; end ; end ; end


