# frozen_string_literal: true

module MixinSupport
  def random_string(count)
    Random.new.bytes((count + 1) / 2).split('').map do |b| b.ord.to_s(16)end.join[0...count]
  end

  def tmpfile
    filename = File.join(Dir.mktmpdir, random_string(20))
    File.open(filename, 'w') do |f|
      f.print(random_string(20))
    end
    filename
  end
end

World(MixinSupport)
