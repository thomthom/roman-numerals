require_relative 'roman'

module RomanNumeralTests

  extend self

  # @return [Array]
  def failures
    @failures ||= []
    @failures
  end

  # @param [Object] from
  # @param [Object] expected
  # @param [Object] actual
  def assert_conversion(from, expected, actual)
    if expected == actual
      print '.'
    else
      print 'F'
      failures << "Expected: #{from.inspect} => #{expected.inspect} got #{actual.inspect}"
    end
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

  def report_summary
    puts
    failures.each { |failure|
      puts failure
    }
    puts 'All tests passed!' if failures.empty?
  end

  def run
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

    report_summary
  end

end

RomanNumeralTests.run
