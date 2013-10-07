#encoding: utf-8

module Kernel
  Modules = [ :bcd ]

  def rdoba *options
    options.each do |option|
      key, value = ( option.is_a?( Hash ) &&
      [ ( k = option.keys.shift ).to_s.to_sym, option[ k ] ] ||
      [ option.to_s.to_sym ] )
      case key
      when :mixin
        require "rdoba/mixin"
        Rdoba.mixin value
      when :log, :debug
        require "rdoba/#{key}"
        Rdoba.log( { :in => self }.merge( value || {} ) ) # TODO move log method into module
        # TODO and resolve some troubles with eval in main
      when :slovo
        require "rdoba/#{key}"
        Rdoba.slovo value
      else
        Kernel.puts STDERR, "Unknown rdoba module named as '#{key.to_s}'"
        nil; end ||
      if Modules.include? key
        require "rdoba/#{key}"; end; end; end; end

require 'rbconfig'

module Rdoba
   def self.gemroot name = nil, path = ''
      if !gem( name )
         raise "Invalid gem named as #{name.inspect}" ; end
      g = Gem::Specification.find_by_name( name )
      File.join g.full_gem_path, path
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

