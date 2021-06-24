# frozen_string_literal: true

require 'rdoba'
require 'tmpdir'
require 'open3'
require 'coveralls'
require 'codeclimate-test-reporter'
require 'simplecov'
require 'rspec/expectations'

# specific external test/development libraries
#
#
Coveralls.wear!
CodeClimate::TestReporter.start
SimpleCov.start
##############################################

RdobaSimSimpleHead = <<~HEAD
  #!/usr/bin/env ruby
  
  require 'rdoba'
HEAD

RdobaCodeClassDeclaration = <<~HEAD
  class Cls
    def initialize
      log > {:variable=>"value"}
    end
  end
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
      %i[
        basic
        extended
        enter
        leave
        compat
        timestamp
        pid
        function_name
        function_line
        function
      ].include?(k.to_sym) && k.to_sym || nil
    end.compact
end

def rdoba_sim(sub, cmd, *args)
  echo = nil
  case sub
  when :log, :debug
    case cmd
    when :init
      $tmpdir ||= Dir.mktmpdir
      @tmpfile ||= File.join($tmpdir, 'tmp.log')

      if args[1] == 'class'
        @deep = 1
        @inithead = RdobaSimClsHead
      else
        @deep = 0
        @inithead = RdobaSimSimpleHead
      end
      @echo = ''
      @init = ''
      puts @inithead
    when :apply
      opts = match_keywords args[1]

      #      opts = opts.size > 2 && opts || opts.size > 0 && opts[ 1 ] || nil
      param =
        case args[0]
        when 'io'
          { io: "File.new( File.join( '#{@tmpfile}' ), 'w+' )", functions: :basic }
        when 'as'
          { as: ':self', functions: :basic }
        when 'in'
          { in: 'Cls', functions: :basic }
          #      when /in.*as/
          #        { :in => "Cls", :as => args[ 2 ].to_sym, :functions => :basic }
        when 'prefix'
          #        basic|extended|enter|leave|compat
          { args[0].to_sym => opts, :functions => :basic }
        when 'functions'
          { args[0].to_sym => opts }
        else
          { functions: :basic }
        end

      if args[2]
        param.merge!(as: args[2].to_sym)
      end

      param =
        '{' + (param).to_a.map do |v| "#{v[0].inspect} => #{v[1].is_a?(String) && v[1] || v[1].inspect}"end.join(',') +
          '}'

      @echo << '   ' * @deep + "rdoba :#{sub} => #{param}\n"
    when :func
      call =
        case args[0]
        when 'keyword'
          'self'
        when 'invalid keyword'
          'errlog'
        when /^db/
          @echo << "self.dbgl = 0xff\n"
          args[0]
        else
          (args[0] || :log).to_sym
        end

      sep = (args[1] == :e) && '.' || ' '
      param = []
      args[2..-1].each do |arg|
        case arg
        when NilClass
        when Symbol
          param << " #{arg}"
        else
          param << " #{arg.inspect}"
        end
      end
      str = "#{call}#{sep}#{args[1]}#{param.join(',')}"
      echo = format str
      @echo << echo
    when :close
      while @deep > 0
        @deep -= 1
        @echo << (format 'end')
      end
    when :declare
      @echo << (format RdobaCodeClassDeclaration)
    when :create
      @echo << (format 'Cls.new')
    when :call
      @echo << (format 'Cls.singleton')
    when :def
      if @inithead == RdobaSimClsHead
        @deep = 1
      else
        @deep = 0
      end
      echo =
        case args[0]
        when :init
          @deep += 1
          format 'def initialize'
        when :single
          @deep += 1
          format 'def self.singleton'
        else
          ''
        end
      @echo << echo
    when :exec
      if !@echo.empty?
        store
        puts '-' * 15

        File.chmod 0755, @tmpfile
        Open3.popen3(@tmpfile) do |stdin, stdout, stderr, wait_thr|
          @out = stdout.read
          @err = stderr.read
        end
        @echo = ''
      end
      res =
        case args[0]
        when :file
          File.new(@tmpfile, 'r').read
        when :stdout
          @out
        when :stderr
          @err
        else
          return
        end
      puts res
      res
    end
  end
end

at_exit { $tmpdir && (FileUtils.remove_entry_secure $tmpdir) }
