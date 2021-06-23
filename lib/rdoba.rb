# encoding: utf-8

module Kernel
  Modules = [:bcd, :mixin, :log, :debug]

  def rdoba(*options)
    options.each do |option|
      (option.is_a?(Hash) && option || { option.to_s.to_sym => {} }).each_pair do |key, value|
        if Modules.include? key
          require "rdoba/#{key}"
          if Rdoba.methods.include? key
            if !value.is_a? Hash
              value = { value: value }
            end
            value.replace({ self: self }.merge value)
            Rdoba.send key, value
          end
        end
      end
    end
  end
end

require 'rbconfig'

module Rdoba
  def self.gemroot(name = nil, path = '')
    if !gem(name)
      raise "Invalid gem named as #{name.inspect}"
    end
    g = Gem::Specification.find_by_name(name)
    File.join g.full_gem_path, path
  end

  def self.os
    @@os ||=
      (
        host_os = RbConfig::CONFIG['host_os']
        case host_os
        when /(mswin|msys|mingw|cygwin|bccwin|wince|emc)/
          plat = $1 == 'mswin' && 'native' || $1
          out = `ver`.encode('US-ASCII', invalid: :replace, undef: :replace)
          if out =~ /\[.* (\d+)\.([\d\.]+)\]/
            "windows-#{plat}-#{$1 == '5' && 'xp' || 'vista'}-#{$1}.#{$2}"
          else
            "windows-#{plat}"
          end
        when /darwin|mac os/
          'macosx'
        when /linux/
          'linux'
        when /(solaris|bsd)/
          "unix-#{$1}"
        else
          raise "unknown os: #{host_os.inspect}"
        end
      )
  end
end
