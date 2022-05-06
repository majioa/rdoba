#!/usr/bin/ruby -KU
# frozen_string_literal: true

class String
  def to_res
    ostr = dup
    res = ''
    while true
      m = ostr.match(%r{(?:([+\[\]\\().*?{}^$/|])|«([^«]*)»)}u)
      break unless m

      res += m.pre_match + (m[2] || (m[1] && ('\\' + m[1])))
      ostr = m.post_match
    end

    res + ostr
  end

  def to_re
    /#{to_res}/ui
  end
end
