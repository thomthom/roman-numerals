# frozen_string_literal: true

class RomanNumeral < Numeric

  # @private
  # Data structure representing Roman numerals.
  #
  # @!attribute [r] name
  #   Roman numeral representation.
  #   @return [String]
  #
  # @!attribute [r] value
  #   Decimal representation.
  #   @return [Integer]
  Token = Struct.new(:name, :value)
  private_constant :Token

end
