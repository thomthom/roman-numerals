# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'

require 'roman'

class RomanNumeralTest < Minitest::Test

  # @param [Object] from
  # @param [Object] expected
  # @param [Object] actual
  def assert_conversion(from, expected, actual)
    message = "Expected: #{from.inspect} => #{expected.inspect} got #{actual.inspect}"
    assert_equal(expected, actual, message)
  end

  # @param [String] roman
  # @param [Integer] decimal
  def assert_to_decimal(roman, decimal)
    numeral = RomanNumeral.new(roman)
    assert_conversion(roman, decimal, numeral.decimal)
  end

  # @param [Integer] decimal
  # @param [String] roman
  def assert_to_roman(decimal, roman)
    numeral = RomanNumeral.new(decimal)
    assert_conversion(decimal, roman, numeral.roman)
  end

  # @param [String] roman
  # @param [Integer] decimal
  def assert_roundtrip(roman, decimal)
    assert_to_decimal(roman, decimal)
    assert_to_roman(decimal, roman)
  end


  def test_class
    numeral = RomanNumeral.new(101)
    assert_kind_of(Numeric, numeral)
    assert_kind_of(Comparable, numeral)
  end

  def test_standard_forms
    # https://en.wikipedia.org/wiki/Roman_numerals#Standard_form
    assert_roundtrip('XXXIX', 39)
    assert_roundtrip('CCXLVI', 246)
    assert_roundtrip('DCCLXXXIX', 789)
    assert_roundtrip('MMCDXXI', 2421)

    assert_roundtrip('CLX', 160)
    assert_roundtrip('CCVII', 207)
    assert_roundtrip('MIX', 1009)
    assert_roundtrip('MLXVI', 1066)

    assert_roundtrip('MDCCLXXVI', 1776)
    assert_roundtrip('MCMXVIII', 1918)
    assert_roundtrip('MCMLIV', 1954)
    assert_roundtrip('MMXIV', 2014)
  end

  def test_non_standard_formats
    assert_to_decimal('MCMLXXXIII', 1983) # Standard (baseline)
    assert_to_decimal('MCMXXCIII', 1983)
    assert_to_decimal('MCMLXXXIII', 1983)
    assert_to_decimal('MCMXXCIIV', 1983)
  end

  def test_large_values_unicode_combining_overline
    assert_roundtrip('I̅V̅DVI', 4_506)
    assert_to_decimal('MV̅DVI', 4_506) # Alternative
    assert_roundtrip('L̅X̅MMMCCCXXXIX', 63_339)
    assert_roundtrip('C̅C̅X̅C̅I̅X̅DLV', 299_555)
    assert_to_decimal('C̅C̅X̅C̅MX̅DLV', 299_555) # Alternative
    assert_roundtrip('M̅M̅D̅C̅L̅X̅V̅II', 2_665_002)
  end

  def test_large_values_ascii_notation
    assert_to_decimal('_I_VDVI', 4_506)
    assert_to_decimal('M_VDVI', 4_506) # Alternative
    assert_to_decimal('_L_XMMMCCCXXXIX', 63_339)
    assert_to_decimal('_C_C_X_C_I_XDLV', 299_555)
    assert_to_decimal('_C_C_X_CM_XDLV', 299_555) # Alternative
    assert_to_decimal('_M_M_D_C_L_X_VII', 2_665_002)
  end

  def test_large_values_ascii_notation_invalid_tokens
    assert_raises(ArgumentError) do
      RomanNumeral.new('_C̅')
    end
  end

  def test_zero
    assert_roundtrip('N', 0)
  end

  def test_zero_incorrectly_used
    # For now the `N` is ignored, falling in line with the flexible parsing
    # allowing for alternate combinations.
    assert_to_decimal('MCMLXXXNIII', 1983)
  end

  def test_negative_values
    assert_raises(RangeError) do
      RomanNumeral.new(-42)
    end
  end

  def test_too_large_value
    assert_raises(RangeError) do
      RomanNumeral.new(4_000_000)
    end
  end

  # Arithmetic operations
  def test_arithmetic_operation_add
    result = RomanNumeral.new(20) + RomanNumeral.new(1983)
    assert_kind_of(RomanNumeral, result)
    assert_equal(2003, result)
  end

  def test_arithmetic_operation_subtract
    result = RomanNumeral.new(1983) - RomanNumeral.new(31)
    assert_kind_of(RomanNumeral, result)
    assert_equal(1952, result)
  end

  def test_arithmetic_operation_multiply
    result = RomanNumeral.new(486) * RomanNumeral.new(2)
    assert_kind_of(RomanNumeral, result)
    assert_equal(972, result)
  end

  def test_arithmetic_operation_divide
    result = RomanNumeral.new(486) / RomanNumeral.new(2)
    assert_kind_of(RomanNumeral, result)
    assert_equal(243, result)
  end

  def test_arithmetic_operation_compare
    numeral = RomanNumeral.new(486)
    assert_equal(-1, numeral <=> RomanNumeral.new(500))
    assert_equal(0, numeral <=> RomanNumeral.new(486))
    assert_equal(1, numeral <=> RomanNumeral.new(200))
  end

  # Interoperability with Integer
  def test_arithmetic_operation_add_to_integer
    result = 20 + RomanNumeral.new(1983)
    assert_kind_of(RomanNumeral, result)
    assert_equal(2003, result)
  end

  def test_arithmetic_operation_add_integer
    result = RomanNumeral.new(1983) + 20
    assert_kind_of(RomanNumeral, result)
    assert_equal(2003, result)
  end

  def test_arithmetic_operation_subtract_from_integer
    result = 1983 - RomanNumeral.new(31)
    assert_kind_of(RomanNumeral, result)
    assert_equal(1952, result)
  end

  def test_arithmetic_operation_subtract_integer
    result = RomanNumeral.new(1983) - 31
    assert_kind_of(RomanNumeral, result)
    assert_equal(1952, result)
  end

  def test_arithmetic_operation_multiply_integer
    result = 2 * RomanNumeral.new(486)
    assert_kind_of(RomanNumeral, result)
    assert_equal(972, result)
  end

  def test_arithmetic_operation_multiply_by_integer
    result = RomanNumeral.new(486) * 2
    assert_kind_of(RomanNumeral, result)
    assert_equal(972, result)
  end

  def test_arithmetic_operation_divide_integer
    result = 486 / RomanNumeral.new(2)
    assert_kind_of(RomanNumeral, result)
    assert_equal(243, result)
  end

  def test_arithmetic_operation_divide_by_integer
    result = RomanNumeral.new(486) / 2
    assert_kind_of(RomanNumeral, result)
    assert_equal(243, result)
  end

  def test_comparable_with_right_hand_integer
    numeral = RomanNumeral.new(486)
    assert_equal(-1, numeral <=> 500)
    assert_equal(0, numeral <=> 486)
    assert_equal(1, numeral <=> 200)
  end

  def test_comparable_with_left_hand_integer
    numeral = RomanNumeral.new(486)
    assert_equal(1, 500 <=> numeral)
    assert_equal(0, 486 <=> numeral)
    assert_equal(-1, 200 <=> numeral)
  end

  def test_to_s
    result = RomanNumeral.new(1983).to_s
    assert_kind_of(String, result)
    assert_equal('MCMLXXXIII', result)
  end

  def test_to_i
    result = RomanNumeral.new(1983).to_i
    assert_kind_of(Integer, result)
    assert_equal(1983, result)
  end

  def test_to_int
    result = RomanNumeral.new(1983).to_int
    assert_kind_of(Integer, result)
    assert_equal(1983, result)
  end

end
