#encoding: utf-8

require 'test/unit/assertions'

World( Test::Unit::Assertions )

Given 'Apply Rdoba bcd module' do
  require 'rdoba'
end

When  'Rdoba applied in a code' do
  rdoba :bcd
end

Then 'Create a new simple BCD string' do
  @bcd = BCDString.new 12345
  assert @bcd == "\x45\x23\x01",
  "The BCD, which has been converted from an integer, has invalid value"
end

Then 'Parse an integer' do
  @bcd = BCD.parse 12345
  assert @bcd == "\x45\x23\x01",
  "The BCD, which has been converted from an integer, has invalid value"
end

Then 'Parse a negative integer' do
  begin
    assert BCD.parse( -12345 ),
    "A negative integer has been parse, that is wrong"
  rescue BCD::ParseError
  end
end

Then 'Check class to BCD of parsed integer' do
  assert @bcd.class == BCDString,
  "BCD of parsed integer has invalid class #{@bcd.class}"
end

Then 'Convert the simple BCD to an integer' do
  assert @bcd.to_i == 12345,
  "The integer that has been converted from BCD has invalid value"
end

Then 'Create a new bignum BCD string' do
  @bcd = BCDString.new 12345098761029384756
  assert @bcd == "\x56\x47\x38\x29\x10\x76\x98\x50\x34\x12"
  .force_encoding( 'ASCII-8BIT' ),
  "The BCD, which has been converted from Bignum integer, has invalid value"
end

Then 'Convert the BCD to a Bignum integer' do
  bignum = @bcd.to_i
  assert bignum.class == Bignum,
  "BCD number converted has invalid class value '#{bignum.class}'"
  assert bignum == 12345098761029384756,
  "BCD number converted to integer has invalid value"
end

Then 'Try to create a BCD class with an erroneous argument' do
  bcd_string = "\x56\x47\x38\x29\x10\x76\x98\x50\x34\xA2"
  bcd_string.extend BCD
  begin
    assert bcd_string.to_i == 0,
    "BCD string has been converted into an integer, that is wrong"
  rescue BCD::ConvertError
  end
end

