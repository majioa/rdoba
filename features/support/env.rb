# frozen_string_literal: true

require 'rdoba'
require 'tmpdir'
require 'open3'
require 'coveralls'
require 'simplecov'
require 'rspec/expectations'

# specific external test/development libraries
#
#
Coveralls.wear!
SimpleCov.start
##############################################

RdobaSimSimpleHead = <<~HEAD
  #!/usr/bin/env ruby

  require 'rdoba'
HEAD

RdobaSimClsHead = <<~HEAD
  #!/usr/bin/env ruby

  require 'rdoba'
  class Cls
HEAD

def format(str)
  puts str
  '   ' * @deep + str + "\n"
end

def store
  file = @inithead + @init + @echo + ("end\n" * @deep)
  puts file
  File.open(@tmpfile, 'w+') do |f|
    f.puts file
  end
end

def match_keywords(keystr)
  keys =
    (keystr || '').split(/[,:\s]/).map do |k|
      %i[basic extended enter leave compat timestamp pid function_name function_line function].include?(k.to_sym) &&
        k.to_sym || nil
    end.compact
end

at_exit { $tmpdir && (FileUtils.remove_entry_secure $tmpdir) }
