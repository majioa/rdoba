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
      else
        Kernel.puts STDERR, "Unknown rdoba module named as '#{key.to_s}'"
        nil; end ||
      if Modules.include? key
        require "rdoba/#{key}"; end; end; end; end
