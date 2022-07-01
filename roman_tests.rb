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
  def assert_convert(from, expected, actual)
    if expected == actual
      print '.'
    else
      print 'F'
      failures << "Expected: #{from.inspect} => #{expected.inspect} got #{actual.inspect}"
    end
  end

  # @param [String] roman
  # @param [Integer] decimal
  def assert_roman(roman, decimal)
    numeral = RomanNumeral.new(decimal)
    assert_convert(decimal, roman, numeral.roman)

    numeral = RomanNumeral.new(roman)
    assert_convert(roman, decimal, numeral.decimal)
  end

  def run
    # https://en.wikipedia.org/wiki/Roman_numerals#Standard_form
    assert_roman('XXXIX', 39)
    assert_roman('CCXLVI', 246)
    assert_roman('DCCLXXXIX', 789)
    assert_roman('MMCDXXI', 2421)

    assert_roman('CLX', 160)
    assert_roman('CCVII', 207)
    assert_roman('MIX', 1009)
    assert_roman('MLXVI', 1066)

    assert_roman('MDCCLXXVI', 1776)
    assert_roman('MCMXVIII', 1918)
    assert_roman('MCMLIV', 1954)
    assert_roman('MMXIV', 2014)

    puts
    failures.each { |failure|
      puts failure
    }
    puts 'All tests passed!' if failures.empty?
  end

end

RomanNumeralTests.run
