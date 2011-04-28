#!/usr/bin/ruby

class Object
    attr_reader :debug

    eval "$debug_#{__FILE__.gsub(/[^\w\d_]/,'_')} = 0"
    @debug = nil
    @@debug = nil
    eval "$debug_#{self.class} = 0"

public

    def self.debug=(level)
	@@debug = level
    end

    def debug=(level)
	@debug = level
    end

    def dbc(level)
	level = level.to_i
	if level > 0
	    clevel = (
		    @debug || @@debug ||
		    begin; eval "$debug_#{self.class}"; rescue; nil; end ||
		    begin; eval "$debug"; rescue; nil; end
		).to_i
	    (clevel & level) == level
	else
	    false
	end
    end

    def dbp(level, text)
	Kernel.puts text if dbc(level)
    end

    def dbg(level, code, vars = {})
	if dbc(level)
	    if vars
		vars.each_pair do |var, value|
		    instance_variable_set(var, value)
		end
	    end
	    eval code
	end
    end

    def dbp11(text)
	dbp(0x11,text)
    end

    def dbp12(text)
	dbp(0x12,text)
    end

    def dbp14(text)
	dbp(0x14,text)
    end

    def dbp18(text)
	dbp(0x18,text)
    end

    def dbp1C(text)
	dbp(0x1C,text)
    end

    def dbp1F(text)
	dbp(0x1F,text)
    end

    def dbp21(text)
	dbp(0x21,text)
    end

    def dbp22(text)
	dbp(0x22,text)
    end

    def dbp24(text)
	dbp(0x24,text)
    end

    def dbp26(text)
	dbp(0x26,text)
    end

    def dbp28(text)
	dbp(0x28,text)
    end

    def dbp2C(text)
	dbp(0x2C,text)
    end

    def dbp2F(text)
	dbp(0x2F,text)
    end

    def dbp41(text)
	dbp(0x41,text)
    end

    def dbp42(text)
	dbp(0x42,text)
    end

    def dbp44(text)
	dbp(0x44,text)
    end

    def dbp48(text)
	dbp(0x48,text)
    end

    def dbp4F(text)
	dbp(0x4F,text)
    end

    def dbg44(code, vars)
	dbg(0x44,code,vars)
    end

    def dbc2F
	dbc(0x2F)
    end

    alias :__method_missing__ :method_missing
    def method_missing(symbol, *args)
	if symbol.to_s =~ /^dbc([0-9a-fA-F]+)$/
	    dbc($1.to_i(16))
	elsif not args.empty?
	    if symbol.to_s =~ /^dbg([0-9a-fA-F]+)$/
		dbg($1.to_i(16), args.shift, args.shift)
	    elsif symbol.to_s =~ /^dbp([0-9a-fA-F]+)$/
		dbp($1.to_i(16), args.join(','))
	    else __method_missing__(symbol, *args); end
	else __method_missing__(symbol, *args); end
    end
end

