#!/usr/bin/ruby -KU
#coding:utf-8
# frozen_string_literal: true

class String
  def to_res
    ostr = self.dup
    res = ''
    while true
      m = ostr.match(/(?:([+\[\]\\().*?{}^$\/|])|«([^«]*)»)/u)
      break unless m

      res += m.pre_match + (m[2] || m[1] && ('\\' + m[1]))
      ostr = m.post_match
    end

    res + ostr
  end

  def to_re
    /#{to_res}/ui
  end
end
