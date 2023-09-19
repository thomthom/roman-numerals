# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'

require 'roman/ext'

class RomanNumeralExtTest < Minitest::Test

  def test_string_roman
    numeral = 'MCMLXXXIII'.roman

    assert_kind_of(RomanNumeral, numeral)
    assert_equal(1983, numeral)
  end

  def test_string_roman_invalid_characters
    assert_raises(ArgumentError) do
      'Hello World'.roman
    end
  end

  def test_string_roman_invalid_empty
    assert_raises(ArgumentError) do
      ''.roman
    end
  end

  def test_integer_roman
    numeral = 1983.roman

    assert_kind_of(RomanNumeral, numeral)
    assert_equal(1983, numeral)
  end

  def test_integer_roman_invalid_out_of_range
    assert_raises(RangeError) do
      -42.roman
    end
  end

end
