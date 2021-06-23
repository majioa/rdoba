# encoding: utf-8
# frozen_string_literal: true

STDERR.puts "Warning: the module has kept only for backward compatibility\n" \
              "Please use 'rdoba :log' form instead"

require 'rdoba/log'

module Rdoba
  def self.debug(options = {})
    Rdoba.log options
  end
end
