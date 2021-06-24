#encoding: utf-8
# frozen_string_literal: true

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
          plat = Regexp.last_match(1) == 'mswin' && 'native' || Regexp.last_match(1)
          out = `ver`.encode('US-ASCII', invalid: :replace, undef: :replace)
          if out =~ /\[.* (\d+)\.([\d\.]+)\]/
            "windows-#{plat}-#{Regexp.last_match(1) == '5' && 'xp' || 'vista'}-#{Regexp.last_match(1)}.#{Regexp.last_match(2)}"
          else
            "windows-#{plat}"
          end
        when /darwin|mac os/
          'macosx'
        when /linux/
          'linux'
        when /(solaris|bsd)/
          "unix-#{Regexp.last_match(1)}"
        else
          raise "unknown os: #{host_os.inspect}"
        end
      )
  end
end
