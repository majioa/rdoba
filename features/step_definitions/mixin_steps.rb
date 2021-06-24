#coding: utf-8
# frozen_string_literal: true

Допустим(/ꙇє примѣнена подпримѣсь \.([^\s]+) бисера рдоба/i) do |подпримѣсь|
  require 'rdoba'
  case подпримѣсь
  when 'пуздро'
    rdoba mixin: [:case]
  when 'обратка'
    rdoba mixin: [:reverse]
  when 'ли_пущь'
    rdoba mixin: [:empty]
  when 'во_сл'
    rdoba mixin: [:to_h]
  when 'сравнена'
    rdoba mixin: [:compare]
  when 'режь_по'
    rdoba mixin: [:split_by]
  when 'жди_ьже'
    rdoba mixin: [:wait_if]
  when 'время'
    rdoba mixin: [:time]
  when 'пробь'
    rdoba mixin: [:try]
  else
    raise
  end
end

Допустим(/^у нас есть набор чисел$/) do
  @набор = [1, 2, 3, 4, 5, 6, 7, 8]
end

Если(
  /къ (кирилическу|латыньску) слову въ (верхнемъ|нижнемъ|смѣшанѣмъ) пуздрѣ ꙇє примѣненъ приꙇомъ :(ниспуздри|воспуздри)/
) do |ꙇезикъ, пуздро, приꙇомъ|
  стр =
    if /кирилическу/.match?(ꙇезикъ)
      if /верхнемъ/.match?(пуздро)
        'КИРИЛИЧЕСКЫ БУКЫ ЗРИЙ СІИ: Ѡ И Ꙍ'
      elsif /нижнемъ/.match?(пуздро)
        'кирилическы букы зрий сіи: ѡ и ꙍ'
      else
        'КиРиЛиЧеСкЫ бУкЫ зРиЙ сІи: Ѡ и Ꙍ'
      end
    elsif /верхнемъ/.match?(пуздро)
      'LATIN LETTERS SEE THE FOLLOWING: ÆǞ'
      elsif /нижнемъ/.match?(пуздро)
        'latin letters see the following: æǟ'
      else
        'LaTiN lEtTeRs SeE tHe FoLlOwInG: æǞ'
    end

  @плодъ = (приꙇомъ =~ /ниспуздри/) && стр.downcase || стр.upcase
end

Если(/^рассечём его на чётные и нечётные$/) do
  @чётъ, @нечётъ = @набор.split_by { |x| x.even? }
end

Если(/^спробуем вызвать метод :qwer пущя$/) do
  @плодъ = nil.try(:qwer)
end

То(/^(кирилическо|латыньско) слово имаꙇє буквы въ (нижнемъ|верхнемъ) пуздрѣ$/) do |ꙇезикъ, пуздро|
  плодъ =
    if /кирилическо/.match?(ꙇезикъ)
      (пуздро =~ /верхнемъ/) && 'КИРИЛИЧЕСКЫ БУКЫ ЗРИЙ СІИ: Ѡ И Ꙍ' || 'кирилическы букы зрий сіи: ѡ и ꙍ'
    else
      (пуздро =~ /верхнемъ/) && 'LATIN LETTERS SEE THE FOLLOWING: ÆǞ' || 'latin letters see the following: æǟ'
    end

  if @плодъ != плодъ
    raise "Плодна Страза со значенꙇемъ '#{@плодъ}' должна имѣти значенꙇе " \
            "'#{плодъ}'"
  end
end

То(/^Стразовъ приꙇомъ :обратка( сѫ кракомъ| сѫ доведомъ)? повратє обратну Стразу$/) do |доведъ|
  требе =
    case доведъ
    when nil
      'акортс'
    when /кракомъ/u
      "\xB0\xD0\xBA\xD0\xBE\xD0\x80\xD1\x82\xD1\x81\xD1"
    when /доведомъ/u
      'карост'
    end

  исходъ =
    case доведъ
    when nil
      'строка'.reverse
    when /кракомъ/u
      'строка'.reverse :byte_by_byte
    when /доведомъ/u
      'строка'.reverse 2
    end

  if исходъ != требе
    raise "Ложнъ исходъ '#{исходъ}' ꙇє повратнъ отъ приꙇома :обратка#{доведъ}, требуꙇє '#{требе}'"
  end
end

То(/^приꙇомъ :ли_пущь рода (пущь|лжа|нове вещи) повратє (вѣрнъ|лжъ)$/) do |вещь, поврать|
  поврать = (поврать == 'вѣрнъ') && true || false
  исходъ =
    case вещь
    when 'пущь'
      nil.empty? == поврать
    when 'лжа'
      false.empty? == поврать
    when 'нове вещи'
      Object.new.empty? == поврать
    end
  if !исходъ
    raise "Ложнъ исходъ ꙇє повратнъ отъ приꙇома :ли_пущь рода #{вещь}"
  end
end

Если(
  /^(ровнъ|двуглубнъ|триглубнъ) наборъ( сѫ одинакыми частьми)? ꙇє пречиненъ во словникъ( приꙇомомъ :во_сл сѫ клѵчемъ :кромѣ_двоꙇниковъ)?$/
) do |видъ, одинакъ, клѵчь|
  @вещь =
    case видъ
    when 'ровнъ'
      ['aa', 0, 'bb', 1].to_h
    when 'двуглубнъ'
      if одинакъ
        if клѵчь
          [['aa', 0], ['aa', 0]].to_h(save_unique: true)
        else
          [['aa', 0], ['aa', 0]].to_h
        end
      else
        [['aa', 0], ['bb', 1]].to_h
      end
    when 'триглубнъ'
      [['aa', 0, 1], ['bb', [1, 0]]].to_h
    end
end

То(/^тъꙇи имѣꙇє ровнъ словникъ сѫ (пущими |ровнѣми |двуглубнѣми )?значѣми$/) do |видъ|
  @схъ =
    if /пущими/u.match?(видъ)
      { 'aa' => nil, 0 => nil, 'bb' => nil, 1 => nil }
    elsif /ровнѣми/u.match?(видъ)
      { 'aa' => 0, 'bb' => 1 }
    else
      { 'aa' => [0, 1], 'bb' => [1, 0] }
    end

  if @вещь != @схъ
    raise "Наборъ '#{@вещь}' требуꙇє быти '#{@схъ}'"
  end
end

То(/^тъꙇи имѣꙇє ровнъ словникъ сѫ (однимъ|двами) двуглубн(?:ѣмъ|ѣмы) знач(?:ѣмъ|ѣмы)$/) do |видъ|
  @схъ =
    if /двами/.match?(видъ)
      { 'aa' => [0, 0] }
    else
      { 'aa' => [0] }
    end

  if @вещь != @схъ
    raise "Наборъ '#{@вещь}' требуꙇє быти '#{@схъ}'"
  end
end

Если(/^имѣмы двѣ Стразы$/) do
  @стры = %w[а҆́гнецъ а҆гкѵ́ра]
end

То(
  /^приꙇомъ :сравнена двухъ Стразъ( сѫ презоромъ надъстрочниковъ( ꙇакъ словникъ)?)? повратє (безъ )?одна$/
) do |доведъ, подобье, знакъ|
  поврать = (знакъ =~ /безъ/u) && -1 || 1

  исходъ =
    if доведъ
      if подобье
        @стры[0].compare_to(@стры[1], ignore_diacritics: true) == поврать
      else
        @стры[0].compare_to(@стры[1], :ignore_diacritics) == поврать
      end
    else
      @стры[0].compare_to(@стры[1]) == поврать
    end

  if !исходъ
    raise "Приꙇомъ :сравнена двухъ Стразъ#{доведъ}#{подобье} требуꙇє повратъти '#{поврать}'"
  end
end

То(/^получим два набора чётных и нечётных чисел$/) do
  expect(@чётъ).to be_eql([2, 4, 6, 8])
  expect(@нечётъ).to be_eql([1, 3, 5, 7])
end

То(/^той вернёт пущь$/) do
  expect(@плодъ).to be_nil
end

Если(/^спробуем подождать мало, чтобы условие не выполнилось$/) do
  @плодъ = wait_if(1) { false }
end

Если(/^спробуем подождать мало, чтобы условие выполнилось$/) do
  @плодъ = wait_if(1) { true }
end

Если(/^спробуем подождать долго, чтобы условие выполнилось$/) do
  @плодъ =
    begin
      Timeout.timeout(2) do
        wait_if(10) { true }
      end
    rescue Timeout::Error
      nil
    end
end

То(/^недождёмся$/) do
  expect(@плодъ).to be_nil
end

То(/^той вернёт ложно$/) do
  expect(@плодъ).to be_falsey
end

То(/^той вернёт исте$/) do
  expect(@плодъ).to be_truthy
end

Если(/^спробуем вызвать метод :mtime кута временного$/) do
  @кут = tmpfile
  @время = File.mtime(@кут)
end

Если(/^спробуем вызвать метод :atime кута временного$/) do
  @кут = tmpfile
  @время = File.atime(@кут)
end

Если(/^спробуем вызвать метод :ctime кута временного$/) do
  @кут = tmpfile
  @время = File.ctime(@кут)
end

То(/^той вернёт верно время/) do
  время = @время.strftime('%Y-%m-%d %H:%M:%S.%N %z')
  expect(время).to be_eql(`stat -c %y #{@кут}`.strip)
end

Если(/^ꙇє примѣнена подпримѣсь невѣрна бисера рдоба$/) do
  @проц = Proc.new { rdoba mixin: [:false] }
end

То(/^исключение невѣрнѣ опции вызвано будетъ$/) do
  expect { @проц.call }.to raise_error(Rdoba::Mixin::InvalidOption)
end

# #!/usr/bin/ruby -KU
#
# if $0 == __FILE__
#     p s.to_res
#     [1,2,3,4,5].each_comby do |c|
# 	p c
#     end
#
#     len = 4
#     value = 100
#     p sprintf("%.*X", len, value )
#
#     s = ' 1221 eeee 4564 wwww ' + 258.to_p
#     ppp = s.scanf(' %d %s %d %s %.2+c')
#     p ppp
#     p 258.to_p.to_i(String::BE)
#
#     null = nil
#     p null.class, null
#     null <<= 'qweqweqweqwe'
#     p null.class, null
#     null << 'qweqweqweqwe'
#     p null.class, null
#     i = 12
#     p sprintf("0x%X", i)
#     p sprintf("%.3X", i)
#
#     p '----------'
#
#     str = <<STR
# <font size="4" face="Irmologion Ucs">и3зhде
# повелёніе t кeсарz ѓvгуста, написaти всю2
# вселeнную</font>
# STR
#
# 
#     str = '/font><font size="4">III</font><i>  </i>греч.<font size="4"><i></i>  </font><font size="4" face="Irmologion Ucs">Мёсzца ѓvгуста въ Gi-й дeнь. Слyжба с™и1телю и3 чудотв0рцу тЂхwну, є3пcкпу вор0нежскому.</font>13 августа, Тихона Воронежского, заголовок службы m_aug\13p.hip'
#     re = /<font size="4" face="Irmologion Ucs">([ -"'-\?A-BD-HJ-\[\]`-hj-\}¤¦-§©«-®±µ-·»Ё-ЌЎ-яё-ќў-џҐ-ґ–-—‘-‚“-„†-•…‰‹-›€№™∙]+?)<\/font>/
#
#     p(str.match re)
# end
#
