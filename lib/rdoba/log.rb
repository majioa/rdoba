# frozen_string_literal: true

# Author:: Malo Skrylevo <majioa@yandex.ru>
# License:: MIT
#
# TODO add enum of options hash to convert values to symbols
# TODO make common format, and format for each of methods >, >>, +, -, %, *
# TODO add syntax redefinition ability for the methods >, >>, +, -, %, *
# TODO add multiple output (to more than only the IO)

module Rdoba
  ##
  # Adds a Log instance to the specified object as a variable or directly into
  # the object itself. It returns the rdoba logger object.
  #
  # The argument accepted are only +options+ as a Hash of keys and values.
  #
  # The options keys are accepted the following: +as+, +in+, +functions+,
  # +prefix+, and  +io+.
  #
  # Option +functions+ defines the function list that can be used in it.
  # Undeclared in the list functions just do nothing. It should be provided
  # as an Array of function descriptions of String or Symbol class. The
  # function list is the following: +info+, +warn+, +basic+, +extended+,
  # +leave+, +enter+, +compat+. If omitted it is defaulting to +enter+, and
  # +leave+ functions.
  #
  # The function +info+ provides just info along the code, of course it just
  # can be shewn by +puts+, but it also can be disabled by settings. The call
  # method is :*. Example:
  #
  #     class A
  #        rdoba :log => { :functions => [ :info ] }
  #        def a
  #           log * "Some Info"
  #        end
  #     end
  #
  # The function +warn+ provide justs warn message along the code, of course
  # it just can be shewn by +puts+, or +p+, but it also can be disabled by
  # settings. The call method is :%. Example:
  #
  #     class A
  #        rdoba :log => { :functions => [ :warn ] }
  #        def a
  #           log % "Some Info"
  #        end
  #     end
  #
  # The function +basic+ provides just basic debug message, it also can be
  # disabled by settings. The call method is :>. Example:
  #
  #     class A
  #        rdoba :log => { :functions => [ :basic ] }
  #        def a
  #           v = 123434
  #           log > { :v => v }
  #        end
  #     end
  #
  # The function +extended+ provides extended debug message, class inspect
  # dumps can be used for messages of this function, it also can be
  # disabled by settings. The call method is :>>. Example:
  #
  #     class A
  #        rdoba :log => { :functions => [ :extended ] }
  #        def a
  #           v = ObjectSpace.new
  #           vv = Object.new
  #           log >> { :v => v, :vv => vv }
  #        end
  #     end
  #
  # The function +enter+ provides just debug message on function entry, it
  # also can be disabled by settings. The call method is :+. Example:
  #
  #     class A
  #        rdoba :log => { :functions => [ :enter ] }
  #        def a *args
  #           log + { :args => args }
  #        end
  #     end
  #
  # The function +leave+ provides just debug message on function leave, it
  # also can be disabled by settings. It accepts the just a argument, also
  # returns the provided argument, so it can be used in chain. The call
  # method is :-. Example:
  #
  #     class A
  #        rdoba :log => { :functions => [ :leave ] }
  #        def a
  #           log - 1
  #        end
  #     end
  #
  #     A.new.a # >> 1
  #
  # The function +compat+ provides old style log strings dbgXX just for
  # compatibility, and will be removed.
  #
  # Option +prefix+ defines the prefix that will be shewn before the message
  # text. The following prefix features are available: +timestamp+, +pid+,
  # +function_name+, +function_line+, +function+. The full format is the
  # following:
  #
  #     [<timestamp>]{pid}(<function module>:<function name>.<function line>)
  #     <log type> <text>
  #
  # Here is the function module, function name, function line represents
  # +function+ at whole.
  #
  # The log types are of the functions previously described, and can be:
  # >, >>, ***, %%%, +++, ---.
  #
  # Option +io+ defines the IO to output the debug message to. It must
  # contain all IO methods required. It is defaulting to $stdout. Also
  # StringIO object is allowed.
  #
  #     class A
  #        rdoba :log => { :io => $stderr }
  #        def a
  #           log - 1
  #        end
  #     end
  #
  # Option +as+ defines the name of a method to apply the log functions to.
  # It is defaulting to :log, but when you've specified :self the log functions
  # is being embedded into the caller class instance directly.
  # It should be provided as a Symbol or String. Example:
  #
  #     class A
  #        rdoba :log => { :as => :self, :functions => [ :basic ] }
  #        def a
  #           self > "Debug"
  #        end
  #     end
  #
  # Option +in+ defines the name of a target class or a namespace to log
  # implement to. For toplevel it is defaulting to Kernel namespace, for
  # in-class is defaulting to the self class. It should be provided as a
  # constant of the class/module. Example:
  #
  #     class A
  #        def a
  #           self > "Debug"
  #        end
  #     end
  #
  #     rdoba :log => { :in => A, :functions => [ :basic ] }
  #
  # To compeletly disable the debug messages for the specific class
  # you can use either the RDOBA_LOG environment variable:
  #
  #     $ RDOBA_LOG=0
  #
  # or redeclare the function list for the specific class to empty.
  #
  #     rdoba :log => { :in => MyClass, :functions => [] }
  #
  def self.log(options = {})
    Rdoba::Log.class_variable_set :@@options, options

    functions = [options[:functions]].flatten
    funcname = (options[:as] ||= :log).to_s.to_sym
    target = options[:in] || options[:self]

    if target.class == Object
      Rdoba::Log.log_instance_setup(TOPLEVEL_BINDING.eval 'self')
    else
      Rdoba::Log.log_class_setup target
    end

    if funcname == :self
      Rdoba::Log.define_methods(target, [:+, :-, :>, :>>, :*, :%, :>=, :<=])

      Rdoba::Log.try_define_compat(functions, target)
      target.__rdoba_log__
    else
      if target.class == Object
        Rdoba::Log.log_link_for :instance, target, funcname
      else
        Rdoba::Log.log_link_for :class, target, funcname
      end
    end
  end

  module Log
    @@enabled = !(ENV['RDOBA_LOG'].to_s !~ /^(true|1|)$/)

    def self.enabled?
      @@enabled
    end

    class Error < StandardError
      def initialize(options = {})
        case options
        when :compat
          "Debug compatibility mode can't be enabled for " + 'the specified object'
        when :main
          "An :as option can't be default or set to 'self' value for " +
            'a main application. Please set up it correctly'
        end
      end
    end

    module DebugCompat # TODO compat
      def dbgl
        @dbgl
      end

      def dbgl=(level)
        @dbgl = level
      end

      def dbc(level)
        level = level.to_i
        if level > 0
          clevel =
            @dbgl ||
              begin
                eval "$dbgl_#{self.class}"
              rescue StandardError
                nil
              end
          clevel || (clevel.to_i & level) == level
        else
          false
        end
      end

      def dbp(level, text)
        if dbc level
          Kernel.puts text
        end
      end

      def dbg(level, code, vars = {})
        if dbc level
          if vars
            vars.each_pair do |var, value|
              instance_variable_set(var, value)
            end
          end
          eval code
        end
      end
    end

    module Functions
      include Rdoba::Log::DebugCompat

      def <=(functions = [])
        self.class <= functions
      end

      def >=(functions = [])
        self.class >= functions
      end

      def e(*args)
        io =
          case args.last
          when IO
            args.pop
          else
            $stderr
          end
        e = $! || args.shift
        dump = ([$@ || args.shift] + args).flatten.compact
        io.send :puts, "#{e.class}:%> #{e}\n\t#{dump.join("\n\t")}"
      end

      def get_stack_function_data_at_level(level)
        raise Exception
      rescue Exception
        #TODO check match a method containing '`'
        $@[level] =~ /([^\/]+):(\d+):in `(.*?)'$/
        [$1, $3, $2]
      end
    end

    module ClassFunctions
      def <=(functions)
        Rdoba::Log.update_functions functions, self, :+
      end

      def >=(functions)
        Rdoba::Log.update_functions functions, self, :-
      end
    end

    Initfunc =
      proc do
        self.class_variable_set :@@rdoba_log_prefix, Rdoba::Log.log_init_prefix(self)
        self.class_variable_set :@@rdoba_log_io_method, Rdoba::Log.log_init_io_m
        extend Rdoba::Log::ClassFunctions
        include Rdoba::Log::Functions
        self <= Rdoba::Log.class_variable_get(:@@options)[:functions]
      end

    def self.log_init_prefix(obj, is_self = false)
      options = Rdoba::Log.class_variable_get :@@options
      pfx = ';if Rdoba::Log.enabled?;(Rdoba::Log::log @@rdoba_log_io_method,"'
      if prefix = (options[:prefix].is_a?(Array) && options[:prefix] || [options[:prefix]])
        if prefix.include?(:timestamp)
          pfx << '[#{Time.now.strftime( "%H:%M:%S.%N" )}]'
        end
        if prefix.include?(:pid)
          pfx << '{#{Process.pid}}'
        end
        if prefix.include?(:function)
          pfx << '(#{m,f,l=get_stack_function_data_at_level(2);m}:#{f}.#{l})'
        elsif prefix.include?(:function_name)
          if prefix.include?(:function_line)
            pfx << '(#{_,f,l=get_stack_function_data_at_level(2);f}.#{l})'
          else
            pfx << '(#{get_stack_function_data_at_level(2)[1]})'
          end
        end
      end
      pfx
    end

    def self.log_init_io_m(options = {})
      options = Rdoba::Log.class_variable_get :@@options
      io = options[:io] || $stdout

      # TODO puts costomize
      io_m = io.method :puts
    end

    def self.log_class_setup(obj)
      obj.class_eval 'class RdobaLog;end'
      obj.class_eval 'def __rdoba_log__;@__rdoba_log__||=RdobaLog.new;end'
      obj.class_eval 'class << self; def self.__rdoba_log__;
                         @__rdoba_log__||=RdobaLog.new;end;end'
      obj.class_eval "def self.__rdoba_log__;
                         @__rdoba_log__||=#{obj}::RdobaLog.new;end"
      obj::RdobaLog.class_eval &Initfunc
    end

    def self.log_instance_setup(obj)
      obj.instance_eval 'class ::RdobaLog;end'
      obj.instance_eval 'def __rdoba_log__;$__rdoba_log__||=::RdobaLog.new;end'
      obj.instance_eval 'class << self; def self.__rdoba_log__;
                            $__rdoba_log__||=::RdobaLog.new;end;end'
      obj.instance_eval 'def self.__rdoba_log__;
                            $__rdoba_log__||=::RdobaLog.new;end'
      ::RdobaLog.class_eval &Initfunc
    end

    def self.log_link_for(target, obj, funcname)
      obj.send("#{target}_eval", "def #{funcname};__rdoba_log__;end")
      obj.send("#{target}_eval", "def self.#{funcname};__rdoba_log__;end")
      obj.send(
        "#{target}_eval",
        "class << self; def self.#{funcname};
            __rdoba_log__;end;end"
      )
    end

    def self.define_methods(obj, list)
      list.each do |f|
        evas = "def #{f} *args;__rdoba_log__.#{f} *args;end"
        if obj.class != Object
          obj.class_eval(evas)
        end
        obj.instance_eval(evas)
      end
    end

    def self.try_define_compat(functions, target)
      if functions.include?(:compat)
        list = [:dbgl=]
        (1..0xF).each do |x|
          (1..0xF).each do |y|
            idx = sprintf('%x%x', x, y)
            list << "dbp#{idx}".to_sym << "dbg#{idx}".to_sym
          end
        end
        Rdoba::Log.define_methods(target, list)
      end
    end

    def self.log_functions_set(obj, functions)
      obj.class_variable_set :@@rdoba_log_functions, functions
    end

    def self.log_functions_get(obj)
      obj.class_variable_get :@@rdoba_log_functions
    rescue StandardError
      []
    end

    def self.log_prefix_get(obj)
      obj.class_variable_get :@@rdoba_log_prefix
    rescue StandardError
      ';if true;(File.join "'
    end

    def self.update_functions(functions, obj, method)
      if functions.is_a?(Array) && functions.include?(:*)
        functions = [:basic, :enter, :leave, :warn, :info, :extended, :compat]
      end # TODO compat
      cf = self.log_functions_get obj
      functions =
        cf.send(
          method,
          functions.is_a?(Array) && functions || functions.is_a?(NilClass) && [] || [functions.to_s.to_sym]
        )
      self.log_functions_set obj, functions

      pfx = self.log_prefix_get obj
      code = Rdoba::Log.make_code functions, pfx
      obj.class_eval code
    end

    def self.make_code(functions, pfx)
      code = ''
      psfx = ' ",params);end;end;'
      if functions.include?(:enter)
        code << 'def + *params' + pfx + '<<<' + psfx
      else
        code << 'def + *params;end;'
      end
      if functions.include?(:leave)
        code << 'def - ev' + pfx + '>>> ",[[ev.inspect]]);end;ev;end;'
      else
        code << 'def - ev;ev;end;'
      end
      if functions.include?(:basic)
        code << "def > *params#{pfx}>#{psfx}"
      else
        code << 'def > *params;end;'
      end
      if functions.include?(:extended)
        code << 'def >> *params' + pfx + '>>' + psfx
      else
        code << 'def >> *params;end;'
      end
      if functions.include?(:warn)
        code << "def % *params#{pfx}%%%#{psfx}"
      else
        code << 'def % *params;end;'
      end
      if functions.include?(:info)
        code << "def * *params#{pfx}***#{psfx}"
      else
        code << 'def * *params;end;'
      end
      if functions.include?(:compat)
        code << "$dbgl_#{self.class}=0;"
        (1..0xF).each do |x|
          (1..0xF).each do |y|
            idx = sprintf '%x%x', x, y
            code << "def dbp#{idx}(text); dbp(0x#{idx},text); end;"
            code << "def dbg#{idx}(text); dbg(0x#{idx},text); end;"
          end
        end
      end
      code
    end

    def self.log(io_m, prefix, params)
      text = prefix
      text <<
        params.map do |prm|
          case prm
          when Hash
            r = []
            prm.each do |key, value|
              r << "#{key}: #{value.inspect}"
            end
            r.join(', ')
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
      io_m.call "#{text}\n"
    end
  end
end
