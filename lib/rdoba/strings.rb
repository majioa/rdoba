#!/usr/bin/ruby -KU
#coding:utf-8
# frozen_string_literal: true

warn "Warning: the module 'string' has kept only for backward " \
       "compatibility\nPlease use 'rdoba :mixin' form instead"

class String
  alias to_p to_s
end

rdoba mixin: [:case, :reverse, :compare]
