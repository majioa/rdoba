# frozen_string_literal: true

module Rdoba::Mixin::Time
  require 'ffi/stat'

  def mtime(file)
    FFI::Stat.stat(file)[:st_mtimespec].to_time
  end

  def atime(file)
    FFI::Stat.stat(file)[:st_atimespec].to_time
  end

  def ctime(file)
    FFI::Stat.stat(file)[:st_ctimespec].to_time
  end
end
