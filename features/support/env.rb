require 'rdoba'
require 'tempfile'
require 'open3'
require 'coveralls'
Coveralls.wear!

RdobaSimSimpleHead=<<HEAD
#!/usr/bin/env ruby

require 'rdoba'
HEAD

RdobaSimInHead=<<HEAD
#!/usr/bin/env ruby

require 'rdoba'
class Cls
  def initialize
    self > {:variable=>"value"}
  end
end
HEAD

RdobaSimClsHead=<<HEAD
#!/usr/bin/env ruby

require 'rdoba'
class Cls
HEAD

def format str
  puts str
  "   " * @deep + str + "\n" ; end

def store
  file = @inithead + @init + @echo + ( "end\n" * @deep )
  puts file
  File.open( 'tmp.rb', 'w+' ) do |f|
    f.puts file ; end ; end

def match_keywords keystr
  keys = ( keystr || '' ).split( /[,:\s]/ ).map do |k|
  [ :basic, :extended, :enter, :leave, :compat, :timestamp, :pid,
      :function_name, :function_line ].include?( k.to_sym ) && k.to_sym || nil
    end.compact ; end

def rdoba_sim sub, cmd, *args
  echo = nil
  case sub
  when :log, :debug
    case cmd
    when :init
      opts = match_keywords args[ 1 ]
      opts = opts.size > 1 && opts || opts.size > 0 && opts[ 0 ] || nil

      if args[ 2 ] == 'class'
        @deep = 1
        @inithead = RdobaSimClsHead
      else
        @deep = 0
        @inithead = RdobaSimSimpleHead ; end

      param = case args[ 0 ]
      when 'io'
        { :io => "File.new( 'tmp.log', 'w+' )", :functions => :basic }
      when 'as'
        { :as => ":log", :functions => :basic }
      when 'in'
        @inithead = RdobaSimInHead
        { :in => "Cls", :functions => :basic }
      when 'prefix'
#        basic|extended|enter|leave|compat
        { args[ 0 ].to_sym => opts, :functions => :basic }
      when 'functions'
        { args[ 0 ].to_sym => opts }
      else
        { :functions => :basic }
      end

      param = "{" + ( param ).to_a.map do |v|
        "#{v[ 0 ].inspect} => #{v[ 1 ].is_a?( String ) &&
            v[ 1 ] || v[ 1 ].inspect}" end.join(',') + "}"
      @init = "   " * @deep + "rdoba :#{sub} => #{param}\n"
      puts @init
      @echo = ''

    when :func
      call = case args[ 0 ]
      when 'keyword'
        'log'
      when 'invalid keyword'
        'errlog'
      when /^db/
        @echo << "self.dbgl = 0xff\n"
        args[ 0 ]
      else
        'self'
      end

      sep = ( args[ 1 ] == :e ) && '.' || ' '
      param = []
      args[ 2..-1 ].each do |arg|
        case arg
        when NilClass
        when Symbol
          param << " #{arg}"
        else
          param << " #{arg.inspect}" ; end ; end
      str = "#{call}#{sep}#{args[ 1 ]}#{param.join(',')}"
      echo = format str
      @echo << echo
      while @deep > 0
        @deep -= 1
        @echo << ( format "end" ) ; end

    when :create
      @echo << ( format "Cls.new" )

    when :call
      @echo << ( format "Cls.singleton" )

    when :def
      if @inithead == RdobaSimClsHead
        @deep = 1
      else
        @deep = 0 ; end
      echo = case args[ 0 ]
      when :init
        format 'def initialize'
      when :single
        format 'def self.singleton'
      end
      @deep += 1
      @echo << echo

    when :exec
      if !@echo.empty?
        store
        puts '-' * 15

        File.chmod 0755, 'tmp.rb'
        Open3.popen3( "./tmp.rb" ) do |stdin, stdout, stderr, wait_thr|
          @out = stdout.read
          @err = stderr.read
        end
        @echo = ''
      end
      res = case args[ 0 ]
      when :file
        File.new( 'tmp.log', 'r' ).read
      when :stdout
        @out
      when :stderr
        @err;
      else return; end
      puts res
      res
    end
  end
end

