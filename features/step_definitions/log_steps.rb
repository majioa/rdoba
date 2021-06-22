When /appl(y|ied) Rdoba (Log|Debug) module(?: with set([\w\s,:]+ keywords?| a file name) for :(io|as|in|functions|prefix) options?| with an (invalid) :io option value)?(?: inside a (class))?(?:, and :as option pointing to (self|log))?/ do |var, kind, subs, opt, invalid, cls, as |
  if var == 'ied'
    rdoba_sim kind.downcase.to_sym, :init, subs, cls
  end
  rdoba_sim kind.downcase.to_sym, :apply, opt, subs, as
end

When /issue a call to the function/ do
  rdoba_sim :log, :call
end

When /issue a creation of the class/ do
  rdoba_sim :log, :create
end

When /declare the (Cls) class/ do| cls |
  rdoba_sim :log, :declare, cls
end

When /(issue|define) an output of an? (variable|number|string|array)(?: inside an? (initializer|singleton function))?(?: using (?:the|an?) (keyword|invalid keyword|class))?/ do |issue, subject, inside, cond|

  case inside
  when 'initializer'
    rdoba_sim :log, :def, :init
  when 'singleton function'
    rdoba_sim :log, :def, :single
  else
    rdoba_sim :log, :def ; end

  func = :func
  case subject
  when 'variable'
    rdoba_sim :log, func, cond, :>, { variable: 'value' }
  when 'number'
    rdoba_sim :log, func, cond, :>, 1
  when 'string'
    rdoba_sim :log, func, cond, :>, "string"
  when 'array'
    rdoba_sim :log, func, cond, :>, [ 'array value1', 'array value2' ] ; end

  if issue == 'issue'
    rdoba_sim :log, :close ; end ; end

When /issue an? :(extended|info|warn|enter|leave|compat) output of a variable?/ do |key|
  case key
  when 'extended'
    rdoba_sim :log, :func, :log, :>>, { variable: 'value' }
  when 'info'
    rdoba_sim :log, :func, :log, :*, { variable: 'value' }
  when 'warn'
    rdoba_sim :log, :func, :log, :%, { variable: 'value' }
  when 'enter'
    rdoba_sim :log, :func, :log, :+, { variable: 'value' }
  when 'leave'
    rdoba_sim :log, :func, :log, :-, true # TODO check return
  when 'compat'
    rdoba_sim :log, :func, :dbp11, "'variable: \"value\"'" ; end

  rdoba_sim :log, :close ; end

When /issue an output of the thrown (exception|standard error)(.*)/ do |type, note|
  case type
  when 'exception'
    if note =~ /out/
      rdoba_sim :log, :func, :log, :e, :'Exception.new', :$stdout
    else
      rdoba_sim :log, :func, :log, :e, :'Exception.new' ; end
  when 'standard error'
    if note =~ /notification/
      rdoba_sim :log, :func, :log, :e, :'StandardError.new',
          [ 'standard error extended info' ]
    else
      rdoba_sim :log, :func, :log, :e, :'StandardError.new' ; end ; end ; end

When /look into(?: the)? (stdout|stderr|file|IO)/ do |ioname|
  @res = case ioname
  when 'file'
    rdoba_sim :log, :exec, :file
  when 'IO'
    rdoba_sim :log, :exec, :io
  when 'stdout'
    rdoba_sim :log, :exec, :stdout
  when 'stderr'
    rdoba_sim :log, :exec, :stderr; end ; end

When /(remove|add) :(basic|extended|info|warn|enter|leave|compat) keyword.* :(functions) option(?: to the (self) object)?/ do |act, key, opt, obj|
  if act == 'remove'
    rdoba_sim :log, :func, obj, :>=, [ key.to_sym ]
  else
    rdoba_sim :log, :func, obj, :<=, [ key.to_sym ] ; end ; end

When /clear the :(functions) option/ do |opt|
  rdoba_sim :log, :func, :log, :>=, [ :* ]
end

Then /see the (variable|string|number|array|'true' value) output(?: with the :(basic|extended|info|warn|enter|leave) notice)?(?: preficed with the :(.*))?/ do |subject, notice, prefices|
  case subject
  when 'variable'
    sym = notice && { 'basic' => '>', 'extended' => '>>', 'info' => '***',
        'warn' => '%%%', 'enter' => '<<<', 'leave' => '>>>' }[ notice ] || '>'
    symr = sym.to_s.gsub ( '*' ) do |x| "\\#{x}" end
    prefices = match_keywords prefices
    if prefices.empty?
      if @res !~ /variable: "value"/
        raise "Invalid answer: #{@res}, must be \"variable: \"value\"" ; end
    else
      case prefices
      when [:timestamp]
        if @res !~ /\[\d\d:\d\d:\d\d\.\d{9}\]#{symr} variable: "value"/
          raise "Invalid answer: #{@res.chomp}, must be like " +
              "[00:00:00.000000000]#{sym} variable: \"value\"" ; end
      when [:timestamp, :pid]
        if @res !~ /\[\d\d:\d\d:\d\d\.\d{9}\]\{\d+\}#{symr} variable: "value"/
          raise "Invalid answer: #{@res.chomp}, must be like " +
              "[00:00:00.000000000]{0000}#{sym} variable: \"value\"" ; end
      when [:timestamp, :pid, :function_name]
        if @res !~ /\[\d\d:\d\d:\d\d\.\d{9}\]\{\d+\}\(.+\)#{symr} variable: "value"/
          raise "Invalid answer: #{@res.chomp}, must be like " +
              "[00:00:00.000000000]{0000}(name)#{sym} variable: \"value\"" ; end
      when [:timestamp, :pid, :function_name, :function_line]
        if @res !~ /\[\d\d:\d\d:\d\d\.\d{9}\]\{\d+\}\([^\.]+\.\d+\)#{symr} variable: "value"/
          raise "Invalid answer: #{@res.chomp}, must be like " +
              "[00:00:00.000000000]{0000}(name.0)#{sym} variable: \"value\"" ; end
      when [:timestamp, :pid, :function]
        expect( @res ).to match( /\[\d\d:\d\d:\d\d\.\d{9}\]\{\d+\}\([^:]+:[^\.]+\.\d+\)#{symr} variable: "value"/ )
      else
        raise "Invalid answer: #{@res}"
      end
    end
  when 'string'
    if @res !~ /string/
      raise "Invalid answer: #{@res}, must be \"string\"" ; end
  when 'number'
    if @res !~ /1/
      raise "Invalid answer: #{@res.inspect}, must be \"1\"" ; end
  when "'true' value"
    if @res !~ /true/
      raise "Invalid answer: #{@res.inspect}, must be \"true\"" ; end
  when 'array'
    if @res !~ /array value1, array value2/
      raise "Invalid answer: #{@res.inspect}, must be an enum: \"array value1, array value2\"" ; end ; end ; end

Then /see the (standard error|exception) info(.*)/ do |subject, notice|
  case subject
  when 'exception'
    if @res !~/Exception:%> Exception/
      raise "Invalid answer: #{@res.inspect}, must be like " +
          "'Exception:%> Exception'" ; end
  when 'standard error'
    if notice =~ /notification/
      if @res !~ /StandardError:%> StandardError\n\tstandard error extended info/
        raise "Invalid answer: #{@res.inspect}, must be like " +
            "'StandardError:%> StandardError\n\tstandard error " +
            "extended info'" ; end
    else
      if @res !~ /StandardError:%> StandardError/
        raise "Invalid answer: #{@res.inspect}, must be like " +
            "'StandardError:%> StandardError'" ; end ; end ; end ; end

Then /see(?: a| the)? (nothing|warning|.* error exception)/ do |subject|
  case subject
  when 'nothing'
    unless @res.empty?
      raise "Invalid answer: #{@res.inspect}, must be empty" ; end
  when 'warning'
    if @res !~ /Warning:/
      raise "Invalid answer: #{@res.inspect}, must be a warning " +
          "with the description" ; end
    'log\': main is not a class/module (TypeError)'
  when /no method error/
    if @res !~ /undefined method .* \(NoMethodError\)/
      raise "Invalid answer: #{@res.inspect}, must notify" +
          " that the interpreter has not found the specified method" ; end
  when /name error/
    if @res !~ /.* \(NameError\)/
      raise "Invalid answer: #{@res.inspect}, must notify" +
          " that the the specified name isn't declared" ; end
  else
    raise "Invalid answer: #{@res.inspect}" ; end ; end


Given(/^selected full Rdoba Log test plan( with self keyword)?$/) do |slf|
   @testplan = 'features/support/' +
   if slf
      'fulltest_as_self.rb.in'
   else
      'fulltest_as_log.rb.in' ; end
   unless File.exist? @testplan
      raise "Invalid file #{@testplan} for the specified full test plan" ; end
      end

When(/^we run the test plan$/) do
   Open3.popen3( @testplan ) do |stdin, stdout, stderr, wait_thr|
      @out = stdout.read
      @err = stderr.read ; end ; end

Then(/^we see no error on its output$/) do
   unless @err.empty?
      raise "Error found: #{@err}" ; end ; end

