#!/usr/bin/ruby -KU
# frozen_string_literal: true

require 'rdoba/common'

class Hash
  def deploy!(vars = {})
    replace deploy(vars)
    # TODO add variable copy
  end

  def deploy(vars = {})
    res = {}

    keys.sort do |x, y|
      if x =~ /=$/
        y =~ /=$/ ? x <=> y : -1
      else
        y =~ /=$/ ? 1 : x <=> y
      end
    end.each do |key|
      if key =~ /(.*)=$/
        vars[Regexp.last_match(1)] = self[key]
        next
      elsif key =~ /(.*)@$/
        sym = Regexp.last_match(1)
        eval "res.class.co( :attr_accessor, :#{sym})"
        eval "res.#{sym} = self[key]"
        next
      elsif key =~ /^%([^%].*)/
        next warn 'Warning: undefined variable ' + "#{Regexp.last_match(1).inspect} found. Ignoring..." unless vars.key?(Regexp.last_match(1))

        var = vars[Regexp.last_match(1)].dup
        if var.instance_of?(Hash)
          res |= var.deploy(vars)
        elsif var.instance_of?(String)
          res[var] = nil
        else
          raise "Undeployable hash #{Regexp.last_match(1)} value class #{var.class}"
        end
        next
      elsif key =~ /^%%(.*)/
        key.replace Regexp.last_match(1).to_s
      end

      def deploy_value(value, vars)
        case value.class.to_sym
        when :String
          if value =~ /^%([^%].*)/
            begin
              vars[Regexp.last_match(1)].deploy(vars)
            rescue StandardError
              nil
            end
          elsif value =~ /(.*)%([A-Za-z0-9_А-я]+)(.*)/
            a = [Regexp.last_match(1).to_s, Regexp.last_match(2).to_s, Regexp.last_match(3).to_s]
            a[1] =
              begin
                vars[a[1]].deploy(vars).to_s
              rescue StandardError
                vars[a[1]]
              end
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
