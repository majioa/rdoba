#coding: utf-8
Given(/applied Rdoba slovo module/i) do
   require 'rdoba'
   rdoba :slovo => true ; end

When(/use (?:a )?slovo's method/) do
   @res = []
   @ina = [ 1, 2, 4 ]
   @ina.еже do |x|
      @res << x ; end ; end

Then(/see method proceessing result/) do
   if @res != @ina
      raise "Result array contains #{@res.inspect}, but must have " \
            "#{@ina.inspect} values" ; end ; end

