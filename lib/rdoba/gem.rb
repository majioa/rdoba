#!/usr/bin/ruby -KU
#encoding:utf-8

require 'rbconfig'

module Rdoba
   def self.gemroot gemname = nil, path = ''
      if !gem
         raise "Undefined gem name" ; end
      g = Gem::Specification.find_by_name( gemname )
      File.join g.full_gem_path, 'share', 'settings.yaml'
   end

   def self.os
      @@os ||= (
         host_os = RbConfig::CONFIG['host_os']
         case host_os
         when /(mswin|msys|mingw|cygwin|bccwin|wince|emc)/
            plat = $1 == 'mswin' && 'native' || $1
            out = `ver`.encode( 'US-ASCII',
                  :invalid => :replace, :undef => :replace )
            if out =~ /\[.* (\d+)\.([\d\.]+)\]/
               "windows-#{plat}-#{$1 == '5' && 'xp' || 'vista'}-#{$1}.#{$2}"
            else
               "windows-#{plat}" ; end
         when /darwin|mac os/
            'macosx'
         when /linux/
            'linux'
         when /(solaris|bsd)/
            "unix-#{$1}"
         else
            raise "unknown os: #{host_os.inspect}"
         end)
   end ; end

