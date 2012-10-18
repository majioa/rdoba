Feature: Rdoba BCD testing
   Scenario: Simple BCD creation scenario
      Given Apply Rdoba bcd module
      When Rdoba applied in a code
      Then Create a new simple BCD string
   Scenario: Simple BCD creation scenario
      Given Apply Rdoba bcd module
      When Rdoba applied in a code
      Then Parse an integer
      Then Check class to BCD of parsed integer
   Scenario: Try to parse a negative integer scenario
      Given Apply Rdoba bcd module
      When Rdoba applied in a code
      Then Parse a negative integer
   Scenario: Converting BCD to an integer scenario
      Given Apply Rdoba bcd module
      When Rdoba applied in a code
      When Create a new simple BCD string
      Then Convert the simple BCD to an integer
   Scenario: Bignum BCD creation scenario
      Given Apply Rdoba bcd module
      When Rdoba applied in a code
      When Create a new bignum BCD string
      Then Convert the BCD to a Bignum integer
   Scenario: Erroneous BCD scenario
      Given Apply Rdoba bcd module
      When Rdoba applied in a code
      Then Try to create a BCD class with an erroneous argument

