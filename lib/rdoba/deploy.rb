#!/usr/bin/ruby -KU
require 'rdoba/common'

class Hash

  def deploy!(vars = {})
    self.replace deploy(vars)
    # TODO add variable copy
  end

  def deploy(vars = {})
    res = {}

    self.keys.sort do |x,y|
      if x =~ /=$/
	y =~ /=$/ ? x <=> y : -1
      else
	y !~ /=$/ ? x <=> y : 1
      end
    end.each do |key|

      if key =~ /(.*)=$/
	vars[$1] = self[key]
	next

      elsif key =~ /(.*)@$/
	sym = $1
	eval "res.class.co( :attr_accessor, :#{sym})"
	eval "res.#{sym} = self[key]"
	next

      elsif key =~ /^%([^%].*)/
        next $stderr.puts "Warning: undefined variable " +
	    "#{$1.inspect} found. Ignoring..." unless vars.key?($1)
	var = vars[$1].dup
	if var.class == Hash
	  res |= var.deploy(vars)
	elsif var.class == String
	  res[var] = nil
	else
          raise "Undeployable hash #{$1} value class #{var.class}"
	end
	next

      elsif key =~ /^%%(.*)/
	key.replace $1.to_s
      end

      def deploy_value(value, vars)
	case value.class.to_sym
	when :String
	  if value =~ /^%([^%].*)/
	    begin; vars[$1].deploy(vars); rescue; nil end
	  elsif value =~ /(.*)%([A-Za-z0-9_А-я]+)(.*)/
	    a = [ $1.to_s, $2.to_s, $3.to_s ]
	    a[1] = begin; vars[a[1]].deploy(vars).to_s; rescue; vars[a[1]] end
	    a.join
	  else
	    value
	  end
	when :Hash
	  value.deploy(vars)
	when :Array
	  value.map do |sub|
	    deploy_value(sub, vars)
	  end
	else
	  value
	end
      end

      value = self[key]
      res[key] = deploy_value(value, vars)
    end
    res
  end
end

