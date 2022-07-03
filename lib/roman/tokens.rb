# frozen_string_literal: true

class RomanNumeral < Numeric

  # A map of the Roman numerals and their decimal values.
  ROMAN_TOKENS = {
    'M̅' => 1_000_000,
    'D̅' => 500_000,
    'C̅' => 100_000,
    'L̅' => 50_000,
    'X̅' => 10_000,
    'V̅' => 5_000,
    'I̅' => 1_000,
    'M' => 1_000,
    'D' => 500,
    'C' => 100,
    'L' => 50,
    'X' => 10,
    'V' => 5,
    'I' => 1,
    'N' => 0,
  }.freeze
  private_constant :ROMAN_TOKENS

end
