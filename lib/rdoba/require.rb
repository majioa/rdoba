#!/usr/bin/ruby -KU
#coding:utf-8

require 'rdoba/common'
require 'rdoba/debug'

module Kernel
private
  def require_dir(dir, name)
    dbp11 "[require_dir] <<< dir = #{dir}, name = #{name}"
    begin
      rdir = File.join(dir, name)
      return false unless File.directory?(rdir)
      rdir = File.join(dir, name)
      $: << rdir unless $:.include?(rdir)
      dbp14 "[require_dir]> Found dir #{rdir}"
      Dir.foreach(rdir) do |file|
        next unless file =~ /(.*)\.(rb|so)$/
        dbp14 "[require_dir]> Loading ... #{Regexp.last_match(1)}"
        require Regexp.last_match(1)
      end
      true
    rescue
      false
    end
  end

  def sub_require(name)
    dbp11 "[sub_require] <<< name = #{name} "
    $:.each do |dir|
      begin
        Dir.foreach(dir) do |file|
          next unless file =~ /^#{name}\.(rb|so)$/
          dbp14 "[sub_require]> Require Dir #{dir}/#{name} for #{file}"
          r1 = require_dir(dir, name + '.modules')
          r2 = require_dir(dir, name)
          dbp14 "[sub_require]> Require Dir #{(r1 || r2) && 'passed' || 'failed'} ... #{name}"
        end
      rescue
      end
    end unless $".include?(name)
    true
  end

public

  alias :__require__ :require
  def require(name, *opts)
    v = parse_opts(opts)
    dbp11 "[require] <<< name = #{name}"
    begin
      res = __require__ name
    rescue => bang
      puts "Lib internal error: #{$!.class} -> #{$!}\n\t#{$@.join("\n\t")}"
      exit
    end
    dbp14 "[require]> Loaded? #{name}... #{res}"
    res = sub_require(name) if res and v[:recursive]
    res
  end
end

