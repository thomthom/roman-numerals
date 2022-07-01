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


  def test_all
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

    # Non-standard variants
    assert_to_decimal('MCMLXXXIII', 1983) # Standard (baseline)
    assert_to_decimal('MCMXXCIII', 1983)
    assert_to_decimal('MCMLXXXIII', 1983)
    assert_to_decimal('MCMXXCIIV', 1983)

    # Arithmetic operations
    result = RomanNumeral.new(20) + RomanNumeral.new(1983)
    assert_kind_of(RomanNumeral, result)
    assert_equal(2003, result)

    result = RomanNumeral.new(1983) + RomanNumeral.new(20)
    assert_kind_of(RomanNumeral, result)
    assert_equal(2003, result.to_i)

    result = RomanNumeral.new(1983) - RomanNumeral.new(31)
    assert_kind_of(RomanNumeral, result)
    assert_equal(1952, result.to_i)

    result = RomanNumeral.new(486) * RomanNumeral.new(2)
    assert_kind_of(RomanNumeral, result)
    assert_equal(972, result.to_i)

    result = RomanNumeral.new(486) / RomanNumeral.new(2)
    assert_kind_of(RomanNumeral, result)
    assert_equal(243, result.to_i)

    numeral = RomanNumeral.new(486)
    assert_equal(-1, numeral <=> RomanNumeral.new(500))
    assert_equal(0, numeral <=> RomanNumeral.new(486))
    assert_equal(1, numeral <=> RomanNumeral.new(200))

    # Interoperability with Integer
    result = 20 + RomanNumeral.new(1983)
    assert_kind_of(Integer, result)
    assert_equal(2003, result)

    result = RomanNumeral.new(1983) + 20
    assert_kind_of(RomanNumeral, result)
    assert_equal(2003, result.to_i)

    result = RomanNumeral.new(1983) - 31
    assert_kind_of(RomanNumeral, result)
    assert_equal(1952, result.to_i)

    result = RomanNumeral.new(486) * 2
    assert_kind_of(RomanNumeral, result)
    assert_equal(972, result.to_i)

    result = RomanNumeral.new(486) / 2
    assert_kind_of(RomanNumeral, result)
    assert_equal(243, result.to_i)

    numeral = RomanNumeral.new(486)
    assert_equal(-1, numeral <=> 500)
    assert_equal(0, numeral <=> 486)
    assert_equal(1, numeral <=> 200)
    assert_equal(-1, 500 <=> numeral)
    assert_equal(0, 486 <=> numeral)
    assert_equal(1, 200 <=> numeral)
  end

end
