#coding: utf-8
Допустим( /ꙇє примѣнена подпримѣсь пуздро бисера рдоба/i ) do
   require 'rdoba'
   rdoba :mixin => [ :case ]
end

Если(/къ (кирилическу|латыньску) слову въ (верхнемъ|нижнемъ|смѣшанѣмъ) пуздрѣ ꙇє примѣненъ приꙇомъ :(ниспуздри|воспуздри)/) do | ꙇезикъ, пуздро, приꙇомъ |
   стр = if ꙇезикъ =~ /кирилическу/
            if пуздро =~ /верхнемъ/
               'КИРИЛИЧЕСКЫ БУКЫ ЗРИЙ СІИ: Ѡ И Ꙍ'
            elsif пуздро =~ /нижнемъ/
               'кирилическы букы зрий сіи: ѡ и ꙍ'
            else
               'КиРиЛиЧеСкЫ бУкЫ зРиЙ сІи: Ѡ и Ꙍ' ; end
         else
            if пуздро =~ /верхнемъ/
               'LATIN LETTERS SEE THE FOLLOWING: ÆǞ'
            elsif пуздро =~ /нижнемъ/
               'latin letters see the following: æǟ'
            else
               'LaTiN lEtTeRs SeE tHe FoLlOwInG: æǞ' ; end ; end

   @плодъ = ( приꙇомъ =~ /ниспуздри/ ) && стр.downcase || стр.upcase ; end

То(/^(кирилическо|латыньско) слово имаꙇє буквы въ (нижнемъ|верхнемъ) пуздрѣ$/) do | ꙇезикъ, пуздро |
   плодъ = if ꙇезикъ =~ /кирилическо/
              ( пуздро =~ /верхнемъ/ ) &&
                  'КИРИЛИЧЕСКЫ БУКЫ ЗРИЙ СІИ: Ѡ И Ꙍ'||
                  'кирилическы букы зрий сіи: ѡ и ꙍ'
           else
              ( пуздро =~ /верхнемъ/ ) && 
                  'LATIN LETTERS SEE THE FOLLOWING: ÆǞ' ||
                  'latin letters see the following: æǟ' ; end

   if @плодъ != плодъ
      raise "Плодна Страза со значенꙇемъ '#{@плодъ}' должна имѣти значенꙇе " \
            "'#{плодъ}'" ; end ; end

=begin
#!/usr/bin/ruby -KU

if $0 == __FILE__
    p s.to_res
    [1,2,3,4,5].each_comby do |c|
	p c
    end

    len = 4
    value = 100
    p sprintf("%.*X", len, value )

    s = ' 1221 eeee 4564 wwww ' + 258.to_p
    ppp = s.scanf(' %d %s %d %s %.2+c')
    p ppp
    p 258.to_p.to_i(String::BE)

    null = nil
    p null.class, null
    null <<= 'qweqweqweqwe'
    p null.class, null
    null << 'qweqweqweqwe'
    p null.class, null
    i = 12
    p sprintf("0x%X", i)
    p sprintf("%.3X", i)

    p '----------'

    str = <<STR
<font size="4" face="Irmologion Ucs">и3зhде
повелёніе t кeсарz ѓvгуста, написaти всю2
вселeнную</font>
STR


    str = '/font><font size="4">III</font><i>  </i>греч.<font size="4"><i></i>  </font><font size="4" face="Irmologion Ucs">Мёсzца ѓvгуста въ Gi-й дeнь. Слyжба с™и1телю и3 чудотв0рцу тЂхwну, є3пcкпу вор0нежскому.</font>13 августа, Тихона Воронежского, заголовок службы m_aug\13p.hip'
    re = /<font size="4" face="Irmologion Ucs">([ -"'-\?A-BD-HJ-\[\]`-hj-\}¤¦-§©«-®±µ-·»Ё-ЌЎ-яё-ќў-џҐ-ґ–-—‘-‚“-„†-•…‰‹-›€№™∙]+?)<\/font>/

    p(str.match re)
end

=end
