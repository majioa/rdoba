#encoding: utf-8

module Kernel
  Modules = [ :bcd ]

  def rdoba *options
    options.each do |option|
      key, value = ( option.is_a?( Hash ) &&
      [ ( k = option.keys.shift ).to_s.to_sym, option[ k ] ] ||
      [ option.to_s.to_sym ] )
      case key
      when :log, :debug
        require "rdoba/#{key}"
        Rdoba.log( { :in => self }.merge( value || {} ) ) # TODO move log method into module
        # and resolve some troubles with eval in main
      else nil; end || if Modules.include? key
        require "rdoba/#{key}"; end; end; end; end
