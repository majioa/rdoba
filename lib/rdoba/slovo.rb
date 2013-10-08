#coding: utf-8

module Rdoba
   module Slovo
      Methods = {
         :empty? => {
            :name    => :ли_пусто,
            :applyto => [ ::Array, ::ENV, ::Hash, ::String, ::Symbol,
                          ::NilClass, ::Object ] },
         :to_a => {
            :name    => :во_н,
            :applyto => [ ::Array, ::ENV, ::ARGF, ::Enumerable, ::Hash,
                          ::Struct, ::MatchData, ::NilClass,
                          ::RubyVM::InstructionSequence, ::Time, ] },
         :to_s => {
            :name    => :во_с,
            :applyto => [ ::Array, ::ENV, ::ARGF, ::Hash, ::Struct,
                          ::Complex, ::Encoding, ::Exception, ::FalseClass,
                          ::Fixnum, ::Float, ::MatchData, ::Method, ::Module,
                          ::NameError, ::NilClass, ::Object, ::Proc,
                          ::Process::Status, ::Range, ::Rational, ::Regexp,
                          ::String, ::Symbol, '::Thread::Backtrace::Location',
                          ::Time, ::TrueClass, ::UnboundMethod, ] },
         :to_h => {
            :name    => :во_сл,
            :applyto => [ ::Array, ::ENV, ::Hash, ::NilClass, ::Struct ] },
         :uniq => {
            :name    => :ед,
            :applyto => [ ::Array ] },
         :uniq! => {
            :name    => :ед!,
            :applyto => [ ::Array ] },
         :each_byte => {
            :name    => :еже_малко, # парче (бг)?
            :applyto => [ ::ARGF, ::IO, ::String ] },
         :each_char => {
            :name    => :еже_знакъ,
            :applyto => [ ::ARGF, ::IO, ::String ] },
         :each_codepoint => {
            :name    => :еже_чисме,
            :applyto => [ ::ARGF, ::IO, ::String ] },
         :each_line => {
            :name    => :еже_страза,
            :applyto => [ ::ARGF, ::IO, ::String ] },
         :each_key => {
            :name    => :еже_ключь,
            :applyto => [ ::ENV, ::Hash ] },
         :each_pair => {
            :name    => :еже_оба,
            :applyto => [ ::ENV, ::Hash, ::Struct ] },
         :each_value => {
            :name    => :еже_значе,
            :applyto => [ ::Hash ] },
         :each_index => {
            :name    => :еже_брои,
            :applyto => [ ::Array ] },
         :each => {
            :name    => :еже,
            :applyto => [ ::Array, ::ENV, ::ARGF, ::Dir, ::Enumerator, ::Hash,
                          ::IO, ::Range, ::Struct ] } } ; end
   def self.slovo options = {}
      Slovo::Methods.each do |m, v|
         v[ :applyto ].each do |c|
            if c.is_a? String
               begin
                  c.replace( eval c )
               rescue
                  next ; end ; end
            if c.methods.include?( m ) && !c.methods.include?( v[ :name ] )
               c.send :instance_eval, "alias :#{v[ :name ]} :'#{m}'"
               if !c.methods.include?( v[ :name ] )
                  raise "Method #{v[ :name ]} hasn't been added to class #{c}" \
                     "as a class method" ; end ; end
            if c.methods.include?( :instance_methods ) &&
                  c.instance_methods.include?( m ) &&
                  !c.instance_methods.include?( v[ :name ] )
               c.send :class_eval, "alias :#{v[ :name ]} :'#{m}'"
               if !c.instance_methods.include?( v[ :name ] )
                  raise "Method #{v[ :name ]} hasn't been added to class #{c}" \
                        "as an instance method" ; end ; end
               end ; end ; end ; end

