# encoding: utf-8

module Rdoba

   def self.log options = {}
      Rdoba::Log.class_variable_set :@@options, options

      funcname = ( options[ :as ] ||= :log ).to_s.to_sym
      target = options[ :in ] || options[ :self ]

      if target.class == Object
         Rdoba::Log.log_instance_setup( TOPLEVEL_BINDING.eval 'self' )
      else
         Rdoba::Log.log_class_setup target ; end

      if funcname == :self
         Rdoba::Log.define_methods target, [ :+, :-, :>, :>>, :*, :%, :>=, :<= ]

         if ( options[ :functions ] == :compat ) ||
              options[ :functions ].is_a?( Array ) &&
              options[ :functions ].include?( :compat )
            list = [ :dbgl= ]
            (1..0xF).each do |x|
               (1..0xF).each do |y|
                  idx = sprintf "%x%x", x, y
                  list << "dbp#{idx}".to_sym << "dbg#{idx}".to_sym ; end; end
            Rdoba::Log.define_methods target, list ; end
      else
         if target.class == Object
            Rdoba::Log.log_instance_link target, funcname
         else
            Rdoba::Log.log_class_link target, funcname ; end ; end ; end

=begin
  def self.log options = {}
    # options: {
    #   :as - name of method to apply the log functions, default: self
    #   :in - name of class or namespace to implement to the log, default: Kernel
    #   :functions = [
    #     :info
    #     :warn
    #     :basic
    #     :enter
    #     :leave
    #     :extended
    #     :compat - enable old style log strings dbgXX
    #   ]
    #   :prefix = [
    #     :timestamp
    #     :pid
    #     :function_name
    #     :function_line
    #   ]
    #   :io - An IO object to send log output to, default is $stdout
    # }
    # if empty the default value (enter, leave) is applied
    # format of log message is the following:
    # [<timestamp>]{pid}(<function name>)<log type> <debug text>"
    # TODO add enum of options hash to convert values to symbols
    # TODO make common format, and format for each of methods >, >>, +, -, %, *
    # TODO add syntax redefinition ability for the methods >, >>, +, -, %, *
    # TODO add multiple output (to more than only the IO)

#    options[ :io ] = File.new('txt.log','w+')
#    STDERR.puts options.inspect
#    STDERR.puts options[ :io ].method( :puts ).inspect
#    options.map
    funcname = ( options[ :as ] || :self ).to_s.to_sym
    pfx = ';if true;(Rdoba::Log::log @@rdoba_log_io_method,"' #TODO remove if
    io = options[ :io ] || $stdout
    io_m = io.method :puts
    if prefix = ( options[ :prefix ].is_a?( Array ) && options[ :prefix ] ||
          [ options[ :prefix ] ] )
      if prefix.include?( :timestamp )
        pfx << '[#{Time.now.strftime( "%H:%M:%S.%N" )}]'; end
      if prefix.include?( :pid )
        pfx << '{#{Process.pid}}'; end
      if prefix.include?( :function_name )
        if prefix.include?( :function_line )
          pfx << '(#{m,f,l=get_stack_function_data_at_level(2);f+":"+l})'
        else
          pfx << '(#{get_stack_function_data_at_level(2)[1]})'; end ; end ; end

    target = options[ :in ] || Kernel
#    STDERR.puts "self: #{self.to_s}"
#    STDERR.puts "funcname: #{funcname.inspect}"
#    STDERR.puts "target: #{target.inspect}"

    initfunc = Proc.new do
      self.class_variable_set :@@rdoba_log_prefix, pfx
      self.class_variable_set :@@rdoba_log_io_method, io_m
      extend Rdoba::Log::ClassFunctions
      include Rdoba::Log::Functions
      self <= options[ :functions ] ; end

    if funcname == :self
      if target.to_s != 'main'
        # CASE: class Cls; def method; self > end; end
        target.instance_eval &initfunc ; end
      # CASE: main { self > }
      # CASE: class Cls; self > end
      target.class.instance_eval &initfunc
    else
      host = ( target.to_s == 'main' && Kernel || target ) ## TODO check and remove
      if target.to_s != 'main'
        # CASE: class Cls; log > end
        target.class.class_eval "class RdobaDebug;end"
        target.class.send :class_eval, "def #{funcname};@#{funcname}||=RdobaDebug.new;end"
        target.class::RdobaDebug.class_eval &initfunc ; end
      # CASE: main { log > }
      # CASE: class Cls; def method; log > end; end
      host.class_eval "class RdobaDebug;end"
      host.send :class_eval, "def #{funcname};@#{funcname}||=RdobaDebug.new;end"
      host::RdobaDebug.class_eval &initfunc ; end

#    STDERR.puts 2
#    STDERR.puts target.inspect
#    STDERR.puts target.class.methods.sort.inspect
=begin
    target.class.instance_eval do # main { self > }
#    target.class_eval do # main { log > }
      self.class_variable_set( :@@log_prefix, pfx )
      self.class_variable_set( :@@log_io_method, io_m )
      extend Rdoba::Log::ClassFunctions
      include Rdoba::Log::Functions
      STDERR.puts pfx
      STDERR.puts io_m.inspect
      self <= functions; end;
=end
#      end; end

  module Log
    class Error < StandardError
      def initialize options = {}
        case options
        when :compat
          "Debug compatibility mode can't be enabled for " +
          "the specified object"
        when :main
          "An :as option can't be default or set to 'self' value for " +
          "a main application. Please set up it correctly"; end; end; end

      module DebugCompat # TODO compat
         def dbgl
            @dbgl; end

         def dbgl= level
            @dbgl = level; end

         def dbc level
            level = level.to_i
            if level > 0
               clevel = @dbgl || begin
                  eval "$dbgl_#{self.class}"
               rescue
                  nil; end
               clevel || ( clevel.to_i & level ) == level
            else
               false; end; end

         def dbp level, text
            if dbc level
               Kernel.puts text; end; end

         def dbg level, code, vars = {}
            if dbc level
               if vars
                  vars.each_pair do |var, value|
                     instance_variable_set( var, value ); end; end
               eval code; end; end; end

      module Functions
         include Rdoba::Log::DebugCompat

         def <= functions = []
            self.class <= functions; end

         def >= functions = []
            self.class >= functions; end

         def e *args
            io =
            case args.last
            when IO
               args.pop
            else
               $stderr ; end
            e = $! || args.shift
            dump = ( [ $@ || args.shift ] + args ).flatten.compact
            io.send :puts, "#{e.class}:%> #{e}\n\t#{dump.join("\n\t")}"; end

         def get_stack_function_data_at_level( level )
            raise Exception
         rescue Exception
            #TODO check match a method containing '`'
            $@[ level ] =~ /([^\/]+):(\d+):in `(.*?)'$/
            [ $1, $3, $2 ]; end; end

      module ClassFunctions
         def <= functions
            Rdoba::Log::update_functions functions, self, :+ ; end

         def >= functions
            Rdoba::Log::update_functions functions, self, :- ; end; end

      Initfunc = proc do
         self.class_variable_set :@@rdoba_log_prefix,
                                 Rdoba::Log.log_init_prefix( self )
         self.class_variable_set :@@rdoba_log_io_method,
                                 Rdoba::Log.log_init_io_m
         extend Rdoba::Log::ClassFunctions
         include Rdoba::Log::Functions
         self <= Rdoba::Log.class_variable_get( :@@options )[ :functions ]; end

      def self.log_init_prefix obj, is_self = false
         options = Rdoba::Log.class_variable_get :@@options
         #TODO remove if true
         pfx = ';if true;(' + 'Rdoba::Log::log @@rdoba_log_io_method' + ',"'
#         if is_self
#            if obj.to_s == 'main'
#               'Rdoba::Log::log $rdoba_log_io_method'
#            else
#               'ans=self.class.ancestors rescue [ self ];io=ans.each do|an|io=::Object.class_variable_get(:@@rdoba_log_io_method)[an];if io;break io;end;end;Rdoba::Log::log io' ; end
#         else
#            'Rdoba::Log::log @@rdoba_log_io_method' ; end + ',"'
         if prefix = ( options[ :prefix ].is_a?( Array ) && options[ :prefix ] ||
               [ options[ :prefix ] ] )
            if prefix.include?( :timestamp )
               pfx << '[#{Time.now.strftime( "%H:%M:%S.%N" )}]'; end
            if prefix.include?( :pid )
               pfx << '{#{Process.pid}}'; end
            if prefix.include?( :function_name )
               if prefix.include?( :function_line )
                  pfx << '(#{m,f,l=get_stack_function_data_at_level(2);f+":"+l})'
               else
                  pfx << '(#{get_stack_function_data_at_level(2)[1]})'
                  end ; end ; end
         pfx ; end

      def self.log_init_io_m options = {}
         options = Rdoba::Log.class_variable_get :@@options
         io = options[ :io ] || $stdout
         # TODO puts costomize
         io_m = io.method :puts ; end
=begin
      def self.log_main_setup
         ::Object.class_eval "class ::RdobaLog;end"
         ::Object.class_eval "def __rdoba_log__;$__rdoba_log__||=::RdobaLog.new;end"
         ::Object.class_eval "class << self; def self.__rdoba_log__;
                              $__rdoba_log__||=::RdobaLog.new;end;end"
         ::RdobaLog.class_eval &Initfunc ; end

      def self.log_main_link funcname
         ::Object.class_eval "def #{funcname};__rdoba_log__;end"
         ::Object.class_eval "def self.#{funcname};__rdoba_log__;end"
         ::Object.class_eval "class << self; def self.#{funcname};
                              __rdoba_log__;end;end" ; end
=end
      def self.log_class_setup obj
         obj.class_eval "class RdobaLog;end"
         obj.class_eval "def __rdoba_log__;@__rdoba_log__||=RdobaLog.new;end"
         obj.class_eval "class << self; def self.__rdoba_log__;
                         @__rdoba_log__||=RdobaLog.new;end;end"
         obj.class_eval "def self.__rdoba_log__;
                         @__rdoba_log__||=#{obj}::RdobaLog.new;end"
         obj::RdobaLog.class_eval &Initfunc ; end

      def self.log_instance_setup obj
         obj.instance_eval "class ::RdobaLog;end"
         obj.instance_eval "def __rdoba_log__;$__rdoba_log__||=::RdobaLog.new;end"
         obj.instance_eval "class << self; def self.__rdoba_log__;
                            $__rdoba_log__||=::RdobaLog.new;end;end"
         obj.instance_eval "def self.__rdoba_log__;
                            $__rdoba_log__||=::RdobaLog.new;end"
         ::RdobaLog.class_eval &Initfunc ; end

      def self.log_instance_link obj, funcname
         obj.instance_eval "def #{funcname};__rdoba_log__;end"
         obj.instance_eval "def self.#{funcname};__rdoba_log__;end"
         obj.instance_eval "class << self; def self.#{funcname};
                         __rdoba_log__;end;end" ; end

      def self.log_class_link obj, funcname
         obj.class_eval "def #{funcname};__rdoba_log__;end"
         obj.class_eval "def self.#{funcname};__rdoba_log__;end"
         obj.class_eval "class << self; def self.#{funcname};
                         __rdoba_log__;end;end" ; end

=begin
      def self.log_setup_class obj, funcname
         obj.class_eval "class RdobaLog;end"
         obj.class_eval "def #{funcname};@#{funcname}||=RdobaLog.new;end"
         obj.class_eval "class << self; def self.#{funcname};
               @#{funcname}||=RdobaLog.new;end;end"
         obj.class_eval "def self.#{funcname};
               @#{funcname}||=#{obj}::RdobaLog.new;end"
         obj::RdobaLog.class_eval &Initfunc ; end

      def self.log_class_link_self obj
         self.define_methods obj, [ :+, :-, :>, :>>, :*, :%, :>=, :<= ]
      end
=end

      def self.define_methods obj, list
         list.each do| f |
            evas = "def #{f} *args;__rdoba_log__.#{f} *args;end"
            if obj.class != Object
               obj.class_eval evas ; end
            obj.instance_eval evas
         end
      end
=begin
      def self.log_class_link_self1 obj
         self.log_setup_class_self_apply obj
         self.log_setup_class_self_apply obj.class
         obj.class_eval do
            class << self
               Rdoba::Log.log_setup_class_self_apply self
            end
         end
      end

      def self.log_setup_class_self_apply obj
         pfxs = if ::Object.class_variables.include? :@@rdoba_log_prefix
                  ::Object.class_variable_get :@@rdoba_log_prefix
                else
                  {} ; end
         pfxs[ obj ] = Rdoba::Log.log_init_prefix obj, true
         ::Object.class_variable_set :@@rdoba_log_prefix, pfxs

         ios =
         if ::Object.class_variables.include? :@@rdoba_log_io_method
            ::Object.class_variable_get :@@rdoba_log_io_method
         else
            {} ; end
         ios[ obj ] = Rdoba::Log.log_init_io_m
         ::Object.class_variable_set :@@rdoba_log_io_method, ios

         obj.class_eval do
            extend Rdoba::Log::ClassFunctions
            self <= Rdoba::Log.class_variable_get( :@@options )[ :functions ]
            include Rdoba::Log::Functions ; end ; end

      def self.log_setup_main_self obj
         $rdoba_log_prefix = Rdoba::Log.log_init_prefix obj, true
         $rdoba_log_io_method = Rdoba::Log.log_init_io_m
         obj.extend Rdoba::Log::ClassFunctions
         obj.include Rdoba::Log::Functions
         obj <= Rdoba::Log.class_variable_get( :@@options )[ :functions ] ; end
=end
      def self.log_functions_set obj, functions
#         if Rdoba::Log.class_variable_get( :@@options )[ :as ] == :self
#            if obj.to_s == 'main'
#               $rdoba_log_functions = functions
#            else
#               funcs =
#               ( ::Object.class_variable_get :@@rdoba_log_functions ) rescue {}
#               funcs[ obj ] = functions
#               ::Object.class_variable_set :@@rdoba_log_functions, funcs ; end
#         else
            obj.class_variable_set :@@rdoba_log_functions, functions ; end

      def self.log_functions_get obj
#         if Rdoba::Log.class_variable_get( :@@options )[ :as ] == :self
#            if obj.to_s == 'main'
#               $rdoba_log_functions || raise
#            else
#               funcs = ( ::Object.class_variable_get :@@rdoba_log_functions ) rescue {}
#               funcs[ obj ] || raise ; end
#         else
            obj.class_variable_get :@@rdoba_log_functions
      rescue
         [] ; end

      def self.log_prefix_get obj
#         if Rdoba::Log.class_variable_get( :@@options )[ :as ] == :self
#            if obj.to_s == 'main'
#               $rdoba_log_prefix || raise
#            else
#               pfxs = ::Object.class_variable_get :@@rdoba_log_prefix
#               pfxs[ obj ] ; end
#         else
            obj.class_variable_get :@@rdoba_log_prefix
      rescue
         ';if true;(File.join "' ; end

      def self.update_functions functions, obj, method
         if functions.is_a?( Array ) && functions.include?( :* )
            functions = [ :basic, :enter, :leave, :warn, :info, :extended,
                          :compat ] ; end # TODO compat
         cf = self.log_functions_get obj
         functions = cf.send( method, functions.is_a?( Array ) && functions ||
                     functions.is_a?( NilClass) && [] ||
                     [ functions.to_s.to_sym ] )
         self.log_functions_set obj, functions

         pfx = self.log_prefix_get obj
         code = Rdoba::Log::make_code functions, pfx
#         if Rdoba::Log.class_variable_get( :@@options )[ :as ] == :self
#            if obj.to_s == 'main'
#               obj.instance_eval code
#            else
#               obj.instance_eval code
#               obj.class_eval code;
#               end
#         else
            obj.class_eval code;
         end

    def self.make_code functions, pfx
      code = ''
      psfx = ' ",params);end;end;'
      if functions.include?( :enter )
        code << 'def + *params' + pfx + '<<<' + psfx
      else
        code << 'def + *params;end;'; end
      if functions.include?( :leave )
        code << 'def - ev' + pfx + '>>> ",[[ev.inspect]]);end;ev;end;'
      else
        code << 'def - ev;ev;end;'; end
      if functions.include?( :basic )
        code << "def > *params#{pfx}>#{psfx}"
      else
        code << 'def > *params;end;'; end
      if functions.include?( :extended )
        code << 'def >> *params' + pfx + '>>' + psfx
      else
        code << 'def >> *params;end;'; end
      if functions.include?( :warn )
        code << "def % *params#{pfx}%%%#{psfx}"
      else
        code << 'def % *params;end;'; end
      if functions.include?( :info )
        code << "def * *params#{pfx}***#{psfx}"
      else
        code << 'def * *params;end;'; end
      if functions.include?( :compat )
        code << "$dbgl_#{self.class}=0;"
        (1..0xF).each do |x|
          (1..0xF).each do |y|
            idx = sprintf "%x%x", x, y
            code << "def dbp#{idx}(text); dbp(0x#{idx},text); end;"
            code << "def dbg#{idx}(text); dbg(0x#{idx},text); end;"; end; end; end
      code; end

    def self.log io_m, prefix, params
      text = prefix
      text << params.map do |prm|
          case prm
          when Hash
            r = []
            prm.each do |key, value| r << "#{key}: #{value.inspect}" end
            r.join(", ")
          when Array
            prm.join(', ')
          when String
            prm
          else
            prm.inspect
          end
        end.join(', ')
      # NOTE: the shell over text id requires to proper output
      # in multiprocess environment
      io_m.call "#{text}\n"; end ; end ; end
