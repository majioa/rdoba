#!/usr/bin/ruby -KU
#<Encoding:UTF-8>

require 'strscan'
require 'timeout'

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

    def xor(val1)
	val0 = (not not self)
	((val0) and (not val1)) or ((not val0) and (val1))
    end

    def co(method, *args) #calls any method
	eval "#{method}(*args)"
    end

    def to_sym
      to_s.to_sym
    end

    P = [
        'слово',
        'язык',
        'часть речи',
        'время',
        'род',
        'лицо',
        'число',
        'падеж',
        'имя',
        'залог',
        'зрак',
        'разряд',
        'полнота',
        'изменчивость',
        'ограничение',
        'притяжение',
        'исток',
	'образа',
        'формы',
        'близь',
        'соответствия',
        'наборы',
        'чада',
        'осмысления',
        'примеры',
        'значения',
        'смысл',
        'писмя',
        'перевод',
        'пояснение',
        'отсылка',
        'ссылки',
        'сравнение',
    ]

    def to_yml(level = 0)
	res = ''
	res += '---' if level == 0
	res += case self.class.to_s.to_sym
	    when :Hash
		rs = ''
		self.keys.sort do |x,y|
		    ix = P.index(x) #TODO workaround
		    iy = P.index(y)
		    (ix and iy) ? ix <=> iy : (ix ? -1 : (iy ? 1 : x <=> y))
		end.each do |key|
		    value = self[key]
		    rs += "\n" + ' ' * level * 2 + key.to_yml(level + 1)
		    rs += ': ' + value.to_yml(level + 1)
		end
		rs.empty? and "{}" or rs
	    when :Array
		rs = ''
		self.each do |value|
		    rs += "\n" + ' ' * level * 2 + '- ' + value.to_yml(level + 1)
		end
		rs.empty? and "[]" or rs
	    when :Fixnum
		self.to_s
	    when :String
		if self =~ /[-:\s]/
		    "\"#{self.gsub('"','\"')}\""
		else
		    self
		end
	    when :NilClass
		''
	    else
		begin
		    value.to_yaml
		rescue NameError
		    raise "Unsupported class #{self.class}"
		end
	    end
	res
    end
end

module Kernel
private
    def require_dir(dir, name)
	dbp11 "[require_dir] <<< dir = #{dir}, name = #{name}"
	begin
	    rdir = File.join(dir, name)
	    return false unless File.directory?(rdir)
	    rdir = File.join(dir, name)
	    $: << rdir unless $:.include?(rdir)
	    dbp14 "[require_dir]> Found dir #{rdir}"
	    Dir.foreach(rdir) do |file|
		next unless file =~ /(.*)\.(rb|so)$/
		dbp14 "[require_dir]> Loading ... #{$1}"
		require $1
	    end
	    true
	rescue
	    false
	end
    end

    def sub_require(name)
	dbp11 "[sub_require] <<< name = #{name} "
	$:.each do |dir|
	    begin
		Dir.foreach(dir) do |file|
		    next unless file =~ /^#{name}\.(rb|so)$/
		    dbp14 "[sub_require]> Require Dir #{dir}/#{name} for #{file}"
		    r1 = require_dir(dir, name + '.modules')
		    r2 = require_dir(dir, name)
		    dbp14 "[sub_require]> Require Dir #{(r1 || r2) && 'passed' || 'failed'} ... #{name}"
		end
	    rescue
	    end
	end unless $".include?(name)
	true
    end

public

    alias :__require__ :require
    def require(name, options = {})
	dbp11 "[require] <<< name = #{name}"
	begin
	    res = __require__ name
	rescue => bang
	    puts "Lib internal error: #{$!.class} -> #{$!}\n\t#{$@.join("\n\t")}"
	    exit
	end
	dbp14 "[require]> Loaded? #{name}... #{res}"
	res = sub_require(name) if res and options[:recursive]
	res
    end

    alias :__sprintf__ :sprintf
    def sprintf(format, *args)
	nargs = []
	nformat = ''

	fmt = format.split('%')
	nformat = fmt.shift

	while (not fmt.empty?)
	    part = fmt.shift
	    part = '%' + fmt.shift unless part
	    if part =~ /([0-9 #+\-*.]*)([bcdEefGgiopsuXx])(.*)/ and $2 == 'c'
		keys = $1 || ''
		str = $3 || ''
		if keys =~ /(-)?([0-9*]*)(?:\.([0-9*]+)(\+))?/
		    value = args.shift
		    indent = ' ' * ($2 == '*' ? args.shift : $2).to_i
		    plain = value && value.to_p(($3 == '*' ? args.shift : $3 ? $3 : 1).to_i, $4) || ''
		    nformat += ($1 ? plain + indent : indent + plain) + str
		else
		    nformat += '%' + keys + 'c' + str
		    nargs.push args.shift
		end
	    else
		nformat += '%' + part
		l = $1 =~ /\*/ ? 2 : 1
		while l > 0
		    nargs.push args.shift
		    l -= 1
		end
	    end
	end
	__sprintf__(nformat, *nargs).to_p
    end

    def wait_if(timeout = 30)
	begin
	    Timeout::timeout(timeout) do
		while yield(); end
	    end
	    true
	rescue Timeout::Error
	    false
	end
    end
end

class Class
=begin
    @@inherited = {}

    def self.inherited(child)
	@@inherited[self] = [] unless @@inherited.key? self
	@@inherited[self] << child
    end

    def new(*args, &block)
	def match_inherited(cls, args)
	    @@inherited[cls].class != Array ? nil : (@@inherited[cls].each do |child|
		begin
		    mm = child.method(:__match__)
		    return match_inherited(child, args) || child if mm.call(*args)
		rescue
		end
	    end; cls)
	end
	cls = match_inherited(self, args) || self
	i = cls.allocate
	i.method(:initialize).call(*args, &block)
	i
    end
=end
end

class NilClass
    def =~(value)
	value == nil
    end

    def +(value)
	value
    end

    def <<(value)
	[ value ]
    end

    def empty?
	true
    end

    def to_i
	0
    end
    alias :ord :to_i

    def size
	0
    end

    def <=>(value)
	-1
    end
end


class Array

private

    def __comby(i, size)
	s = "0#{sprintf("%.*b", size, i)}0"
	v = { :res => [], :c0 => 0, :c1 => 0, :j => 0}

	def up1(v)
	    sub_j = v[:j] + v[:c1] + 1
	    v[:res] << self[v[:j]...sub_j]
	    v[:j] = sub_j
	    v[:c1] = 0
	end

	def up0(v)
	    sub_j = v[:j] + v[:c0] - 1
	    self[v[:j]...sub_j].each do |x| v[:res] << [x] end
	    v[:j] = sub_j
	end

	s.each_char do |c|
	    if c == '1'
		v[:c1] += 1
		up0(v) if v[:c0] > 1
		v[:c0] = 0
	    else
		v[:c0] += 1
		up1(v) if v[:c1] > 0
	    end
	end
	up0(v) if v[:c0] > 1
	v[:res]
    end

public

    def purge
	self.compact.delete_if {|x| x.empty? }
    end

    def >>(value = nil)
	value ? delete(value) : shift
    end

    def each_comby(*args)
	return self if self.empty? or not block_given?
	if args.include?(:backward)
	    yield [ self.dup ]
	    ((1 << (self.size - 1)) - 2).downto(0) do |i|
		c = __comby(i, self.size - 1)
		yield c
	    end
	else
	    0.upto((1 << (self.size - 1)) - 2) do |i|
		c = __comby(i, self.size - 1)
		yield c
	    end
	    yield [ self.dup ]
	end

	return self
    end

    alias :__get__ :[]
    def [](index, *args)
	return __get__(index.to_i, *args) if index.class == String and index =~ /^\d+$/
	__get__(index, *args)
    end

    alias :__set__ :[]=
    def []=(index, value, *args)
	return __set__(index.to_i, value, *args) if index.class == String and index =~ /^\d+$/
	__set__(index, value, *args)
    end

    def geta(index, options = {}) #TODO => [] + class Index
	dbp11 "[geta] <<< array = #{self.inspect}, index = #{index.inspect}, options = #{options.inspect}"
	options[:сокр] ||= @сокр

	if index.class == Array
	    return self if index == [] or index == ['']
	    index = index.clone
	    value = self[index.shift]
	    (value.class == Hash or value.class == Array) ? value.geta(index, options) : value 
	else
	    geta_value(index, options)
	end
    end

end

class String
    def -(str)
	#TODO make smart search for match in the 'str', when only last subpart matched to 'self'
	len = self.size
	bc = ec = nil
	(0...len).each do |idx|
	    break bc = idx if self[idx] == str[0]
	end
	((bc + 1)...len).each do |idx|
	    break ec = idx if self[idx] != str[idx - bc]
	end if bc
	(not bc) ? self.clone : (not ec) ? self[0, bc] : self[0, bc] + self[ec, len - ec]
    end

    alias :__match__ :=~
    def =~(value)
	if value.class == String
	    self == value
	elsif value.class == Regexp
	    value =~ self
	else
	    __match__(value)
	end
    end

    def rmatch(value)
	self == value || self =~ /^\/([^\/]+)/ && value =~ /#{$1}/
    end

    FirstChar = 0
    alias :__set__ :[]=
    def []=(*args)
      index = args[0]
      str = args[args.size > 2 ? 2 : 1]
      if index.class == Fixnum
	if str.class == String
	  a = self.split(//u)
	  if str.size == 1
	    a[index] = str
	  else
	    a[index] = str.split(//u)
	    a.flatten!
	  end
	  return self.replace(a.join)
	end
      end
      __set__(*args)
    end

    def get(*args)
      index = args[0]
      index.class == Fixnum ? self.split(//u)[index] : self[*args]
    end

    def ord
      a = nil
      self.each_byte do |b|
	c = b & 0xC0
	case c
	when 0xc0
	  a = (b & 0x3F)
	when 0x80
	  return (a << 6) + (b & 0x3F)
	else
	  return b
	end
      end
    end unless self.instance_methods(false).include?(:ord)

    def setbyte(*args)
      __set__(*args)
    end unless self.instance_methods(false).include?(:setbyte)

    def upcase_char(char)
	chr = char.class == String ? char.ord : char.to_i
	if chr >= 0x430 and chr < 0x450
	  chr -= 0x20
	elsif chr >= 0x400 and chr < 0x410 or
	    chr >= 0x450 and chr < 0x482 or
	    chr >= 0x48A and chr < 0x524 or
	    chr >= 0xA642 and chr < 0xA668 or
	    chr >= 0xA680 and chr < 0xA698
	  chr -= 1 if (chr % 1) == 1
	else
	  return chr.chr.__upcase__
	end
	chr.chr
    end

    alias :__upcase__ :upcase
    def upcase(option = nil)
      if option == FirstChar
	r = self.dup
	r[0] = upcase_char(self.ord)
	r
      elsif self.match(/[Ѐ-ҁҊ-ԣꙀ-ꙧꚀꚗ]/u)
	self.split(//u).map do |chr| upcase_char(chr) end.join
      else; __upcase__ end
    end

    def downcase_char(char)
	chr = (char.class == String) ? char.ord : char.to_i
	if chr >= 0x410 and chr < 0x430
	  chr += 0x20
	elsif chr >= 0x400 and chr < 0x410 or
	    chr >= 0x450 and chr < 0x482 or
	    chr >= 0x48A and chr < 0x524 or
	    chr >= 0xA642 and chr < 0xA668 or
	    chr >= 0xA680 and chr < 0xA698
	  chr += 1 if (chr % 1) == 0
	else
	  return chr.chr.__downcase__
	end
	chr.chr
    end

    alias :__downcase__ :downcase
    def downcase(option = nil)
      if option == FirstChar
	r = self.dup
	r[0] = downcase_char(self.ord)
	r
      elsif self.match(/[Ѐ-ҁҊ-ԣꙀ-ꙧꚀꚗ]/u)
	self.split(//u).map do |chr| downcase_char(chr) end.join
      else; __downcase__ end
    end

    alias :to_p :to_s
=begin
    def to_p
	force_encoding('BINARY')
    end

    def force_encoding(*args)
	self
    end unless self.instance_methods(false).include?(:force_encoding)

    def encode(*args)
	self
    end unless self.instance_methods(false).include?(:encode)

    def toutf8
	return self if self.encoding.to_s == 'UTF-8'
	res = ''.encode('UTF-8')

	ss = StringScanner.new(self)
	while ss.scan_until(/[\x80-\xFF]+/x)
	    same = (' ' * ss.matched_size).encode('UTF-8')
	    i = 0
	    ss.matched.each_byte do |byte|
		same.setbyte(i, byte)
		i += 1
	    end
	self res += ss.pre_match[pos..-1].encode('UTF-8') + same

	    ss.pos += ss.matched_size + 1
	end

	res + ss.rest.encode('UTF-8')
    end unless self.instance_methods(false).include?(:toutf8)
=end

    ByteByByte = 0
    alias :__reverse__ :reverse
    def reverse(step = 1)
	case step
	when ByteByByte
	    arr = []
	    self.each_byte do |byte| arr << byte.chr end
	    arr.reverse.join
	when 1
	    __reverse__
	else
	    res = ''
	    offset = (self.size + 1) / step * step - step
	    (0..offset).step(step) do |shift|
		res += self[offset - shift..offset - shift + 1]
	    end
	    res
	end
    end

    BE = 0
    LE = 1

    alias :__to_i__ :to_i
    def to_i(base = 10, be = true)
	# TODO make a conversion of negative numbers
	str = case base
	when BE
	    self.reverse(ByteByByte)
	when LE
	    self
	else
	    return __to_i__(base)
	end

	mul = 1
	res = 0
	str.each_byte do |byte|
	    res += byte * mul
	    mul *= 256
	end

	res.to_i
    end

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
	/#{to_res}/i
    end

    def scanf_re(format)
	fss = StringScanner.new(format) # TODO remove scanner in favor of match
	nformat = ''

	pos = 0
	argfs = []
	while fss.scan_until(/%([0-9 #+\-*]*)(?:\.([0-9]+)(\+)?)?([bcdefgiosuxr])/)
	    argfs << [ fss[1], fss[2], fss[3], fss[4] ]
	    # TODO add performing the special case in fss[1]
	    nformat += fss.pre_match[pos..-1].to_res + case fss[4]
	    when 'x'
		'(?:0[xX])?([a-fA-F0-9]+)'
	    when 'i'
		'([+\-]?[0-9]+)'
	    when 'u'
		'([0-9]+)'
	    when 'e'
		'([+\-]?[0-9]+[eE][+\-]?[0-9]+)'
	    when 'f'
		'([+\-]?[0-9]+\.[0-9]*)'
	    when 'g'
		'([+\-]?[0-9]+(?:[eE][+\-]?[0-9]+|\.[0-9]*))'
	    when 'c'
		fss[2] ? "(.{1,#{fss[2]}})" : "(.)"
	    when 'b'
		'([01]+)b?'
	    when 'o'
		'0([0-9]+)'
	    when 'd'
		'([+\-]?(?:0X)?[A-F0-9.+]+)'
	    when 's'
		'(.+)'
	    when 'r'
		'([IVXLCDMivxlcdm]+)'
	    end

	    pos = fss.pos
	end

	nformat += fss.rest

	[ /#{nformat}/, argfs ]
    end

    (alias :__scanf__ :scanf) if self.instance_methods(false).include?(:scanf)
    def scanf(format, &block)
	(re, argfs) = scanf_re(format)

	ss = StringScanner.new(self)
	res = []
	rline = []
	while ss.scan_until(re)
	    argfs.each_index do |i|
		argf = argfs[i]
		value = ss[i + 1]
		rline << case argf[3]
		when 'x'
		    value.to_i(16)
		when /[diu]/
		    value.to_i
		when /[efg]/
		    value.to_f
		when 'c'
		    value.to_i(argf[2] ? BE : LE)
		when 'b'
		    value.to_i(2)
		when 'o'
		    value.to_i(8)
		when 's'
		    value
		when 'r'
		    value.rom
		end
	    end

	    if block_given?
		pass = []
		(1..block.arity).each do |i| pass << "rline[#{i}]" end
		eval "yield(#{pass.join(', ')})"
	    end

	    res << rline
	end

	res
    end

    def consolize
	ss = StringScanner.new(self)
	res = ''
	ostr = ''
	pos = 0

	while ss.scan_until(/\r/)
	    ostr[0...ss.pre_match.size - pos] = ss.pre_match[pos..-1]
	    pos = ss.pos

	    if ss.post_match[0] == "\n"[0]
		res = ostr
		pos += 1
		ostr = ''
	    end

	end

	ostr[0...ss.rest.size] = ss.rest
	res + ostr
    end

    def hexdump
	res= ''
	i = 0
	self.each_byte do |byte|
	    res << sprintf("%.2X ", byte)
	    i += 1
	    res << "\n" if i % 16 == 0
	end
	res
    end

    alias :__compare__ :<=>
    def <=>(value)
      compare(value)
    end

    def compare(value, *opts)
      if opts.include? :compare_diacritics
	__compare__(value)
      else
	# TODO verify composite range
	def crop_diacritics(x)
	  (x < 0x300 or
	     x > 0x36f and x < 0x483 or
	     x > 0x487 and x < 0xa57c or
	     x > 0xa67d) && x || nil
	end

	(self.unpack('U*').map do |x| crop_diacritics(x)
	end.compact) <=> (value.unpack('U*').map do |x| crop_diacritics(x)
	end.compact)
      end
    end

    def rom
      h = Numeric::Roman.reverse
      keys = h.keys.sort do |x,y| x.size < y.size ? 1 : x.size > y.size ? -1 : x <=> y end
      str = self.upcase
      res = 0
      while str and not str.empty?
	raise "Invalid roman number" if (keys.each do |key|
	    if str =~ /^#{key}(.*)/
	      str = $1
	      res += h[key]
	      break nil
	    end
	  end)
      end
      res
    end
end

class Hash

protected

    def geta_value(cid, options = {})
	res = ((not cid) || cid.empty?) && self || self[cid] ||
		(options[:сокр] && (self[options[:сокр][cid]] || self[options[:сокр].reverse[cid]]))

	if not res and options[:try_regexp]
	    self.keys.each do |key|
		break res = self[key] if key.rmatch(cid)
		if options[:сокр]
		    options[:сокр].each_pair do |val1, val2|
			break res = self[key] if key.rmatch(cid.gsub(/#{val1}/, val2)) or
				key.rmatch(cid.gsub(/#{val2}/, val1))
		    end
		end
	    end
	end

	res
    end

public

    def geta(index, options = {}) #TODO => [] + class Index
	dbp11 "[geta] <<< hash = #{self.inspect}, index = #{index.inspect}, options = #{options.inspect}"
	options[:сокр] ||= @сокр

	if index.class == Array
	    return self if index == [] or index == ['']
	    index = index.clone
	    value = geta_value(index.shift, options)
	    (value.class == Hash or value.class == Array) ? value.geta(index, options) : value 
	else
	    geta_value(index, options)
	end
    end

    def seta(index, value, options = {}) #TODO => [] + class Index
	dbp11 "[seta] <<< index: #{index.inspect}, value: #{value.inspect}, options: #{options.inspect}"
	options[:сокр] ||= @сокр

	return self[index] = value if index.class != Array # TODO spec index

	back = 0
	index = index.reverse.map do |x|
	    if x.empty?
		back += 1
		nil
	    elsif back > 0
		back -= 1
		nil
	    else
		x
	    end
	end.compact.reverse
	dbp12 "[seta]> result index: #{index.inspect}"

	obj = nil
	o = self
	dbp14 "[seta]>> self: #{o.inspect}"
	set_idx = index.pop
	par_class = set_idx =~ /^\d+$/ ? Array : Hash
	par_idx = nil
	index.each do |idx|
	    unless o
	      dbp14 "[seta]>> parent idx: #{par_idx.inspect}, idx: #{idx.inspect}, parent obj: #{o.inspect}"
	      o = idx =~ /^\d+$/ && [] || {}
	      obj[par_idx] = o
	    end
	    obj = o
	    o = (obj.class == Hash) ? obj.geta_value(idx, options) : obj[idx]
	    dbp14 "[seta]>> cur idx: #{idx.inspect}, parent obj: #{obj.inspect}, obj: #{o.inspect}"
	    unless o
		if idx == index.last
		    o = par_class.new
		    obj[idx] = o
		else
		  par_idx = idx =~ /^\d+$/ && idx.to_i || idx
		end
	    end
	end

	raise "Invalid path" unless o # TODO special exception

	o[set_idx] = value
    end

    def |(inval)
	res = self.dup
	inval.each_pair do |key, val|
	    if val.class == res[key].class
		if val.class == Hash
		    res[key] |= inval[key]
		elsif val.class == Array
		    res[key].concat val
		else
		    res[key] = val
		end
	    else
		res[key] = val
	    end
	end
	res
    end

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

  def reverse!
    replace(reverse)
  end

  def reverse
    h = {}
    self.each_pair do |key, value|
      if h.key? value
	if h[value].class == Array
	  h[value] << key
	else
	  h[value] = [ h[value], key ]
	end
      else
	h[value] = key
      end
    end
    h
  end
end

class Numeric
    Roman = { 1 => 'I', 4 => 'IV', 5 => 'V', 9 => 'IX', 10 => 'X', 40 => 'XL', 50 => 'L',
	    90 => 'XC', 100 => 'C', 400 => 'CD', 500 => 'D', 900 => 'CM', 1000 => 'M' }
    Romani = Roman.keys.sort

    def to_rom
	res = ''
	num = self
	i = Romani.size - 1

	while num > 0
	    if num >= Romani[i]
		res << Roman[Romani[i]]
		num -= Romani[i]
	    else
		i -= 1
	    end
	end
	res
    end

    def to_s(base = 10, padding_count = 1, style_formatting = false)
	raise "Base of number can't be equal or less then zero" if base <= 0
	raise "Padding count numberr can't be equal or less then zero" if padding_count <= 0
	value = self
	minus = if value < 0
		value = -value
		true
	    end
	res = ''
	while value != 0
	    value, rem = value.divmod(base)
	    rem += 0x40 - 0x39 if rem >= 10
	    res += (0x30 + rem).chr
	end
	res += "0" * (padding_count - res.size) if res.size < padding_count
	res += 'x0' if style_formatting and base == 16
	res += '-' if minus
	res.reverse
    end

    def to_p(padding_count = 1, big_endian = true)
	value = self
	minus = if value < 0
		value = -value
		true
	    end
	res = ''
	while value != 0
	    value, rem = value.divmod(256)
	    res += rem.chr
	end

	pad_char = if minus
		negres += ''
		over = 1
		res.each_byte do |byte|
		    negbyte = 255 - byte + over
		    negres += if negbyte > 255
			    over = 1
			    0
			else
			    over = 0
			    negbyte
			end
		end
		res = negres
		"\xFF"
	    else
		"\0"
	    end

	res += pad_char * (padding_count - res.size) if res.size < padding_count

	(big_endian ? res.reverse(String::ByteByByte) : res).to_p
    end
end

class Fixnum
  alias :__chr__ :chr
  def chr
    if self >= 256
      num = self; s = "\0"; byte = 0x80; a = []
      while num >= 0x40
	s.setbyte(0, byte + (num & 0x3F))
	a << s.dup; num >>= 6; byte = 0x40
      end
      s.setbyte(0, 0xC0 + (num & 0x3F))
      a << s
      a.reverse.join
    else; __chr__ end
  end
end

