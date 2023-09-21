# frozen_string_literal: true

require_relative 'roman/generator'
require_relative 'roman/lexer'
require_relative 'roman/parser'

# A numeric class for Roman numerals.
#
# @example From a decimal integer
#   numeral = RomanNumeral.new(1983)
#   numeral.to_s # => 'MCMLXXXIII'
#   numeral.to_i # => 1983
#
# @example From a roman numeral string
#   numeral = RomanNumeral.new('MCMLXXXIII')
#   numeral.to_s # => 'MCMLXXXIII'
#   numeral.to_i # => 1983
#
# @example Integer arithmetic operations on numerals
#   numeral = RomanNumeral.new(1983) + 20
#   numeral.to_s # => 'MMIII'
#   numeral.to_i # => 2003
#
# @example Roman numeral arithmetic operations on integers
#   numeral = 20 + RomanNumeral.new(1983)
#   numeral.to_s # => 'MMIII'
#   numeral.to_i # => 2003
#
# @example Zero
#   numeral = RomanNumeral.new(0)
#   numeral.to_s # => 'N'
#   numeral.to_i # => 0
#
# @example Large values
#   numeral = RomanNumeral.new(2_665_002)
#   numeral.to_s # => 'M̅M̅D̅C̅L̅X̅V̅II'
#   numeral.to_i # => 2665002
#
# @example Mega Unicode notation
#   numeral = RomanNumeral.new('M̅M̅D̅C̅L̅X̅V̅II')
#   numeral.to_s # => 'M̅M̅D̅C̅L̅X̅V̅II'
#   numeral.to_i # => 2665002
#
# @example Mega ASCII notation
#   # Prefix with `_` to multiply the following numeral by 1000.
#   numeral = RomanNumeral.new('_M_M_D_C_L_X_VII')
#   numeral.to_s # => 'M̅M̅D̅C̅L̅X̅V̅II'
#   numeral.to_i # => 2665002
class RomanNumeral < Numeric

  # @return [Integer]
  attr_reader :decimal

  # @param [Integer, String] input
  def initialize(input)
    super()
    case input
    when Integer
      Generator.check_range(input) # Because the output is lazy-generated.
      @decimal = input
      @roman = nil # Lazy-generated. (See #roman)
    when String
      @decimal = parse_roman(input)
      @roman = input.freeze
    else
      raise TypeError, "expected Integer or String, got #{input.class}"
    end
  end

  # @!attribute [r] roman
  #   @return [Integer]
  # @return [Integer]
  def roman
    @roman ||= generate_roman(@decimal).freeze
    @roman
  end

  # @param [RomanNumeral, Integer] other
  # @return [RomanNumeral]
  def +(other)
    op(:+, other)
  end

  # @param [RomanNumeral, Integer] other
  # @return [RomanNumeral]
  def -(other)
    op(:-, other)
  end

  # @param [RomanNumeral, Integer] other
  # @return [RomanNumeral]
  def *(other)
    op(:*, other)
  end

  # @param [RomanNumeral, Integer] other
  # @return [RomanNumeral]
  def /(other)
    op(:/, other)
  end

  # @param [RomanNumeral, Integer] other
  # @return [Integer]
  def <=>(other)
    case other
    when self.class
      to_i <=> other.to_i
    when Integer
      to_i <=> other
    end
  end

  # @return [Integer]
  def to_i
    decimal
  end
  alias to_int to_i

  # @param [Numeric] other
  # @return [Array(RomanNumeral, RomanNumeral)]
  def coerce(other)
    # > Inheriting classes should also implement arithmetic operator
    # > methods (+, -, * and /) and the <=> operator (see Comparable).
    # https://ruby-doc.org/core-2.7.2/Numeric.html
    case other
    when Integer
      # NOTE: The docs indicate that this should be [self.class.new(other), self],
      #       That means Integer + RomanNumeral returns RomanNumeral.
      [self.class.new(other), self]
    else
      raise TypeError, "unable to coerce to #{other.class}"
    end
  end

  # @return [String]
  def to_s
    roman
  end

  private

  # @param [Symbol] operator
  # @param [Integer] other
  # @return [RomanNumeral]
  def op(operator, other)
    case other
    when self.class
      self.class.new(to_i.public_send(operator, other.to_i))
    when Integer
      self.class.new(to_i.public_send(operator, other))
    else
      raise TypeError, "unable to coerce #{other.class} to #{self.class}"
    end
  end

  # @param [String] input
  # @return [Integer]
  def parse_roman(input)
    lexer = Lexer.new
    tokens = lexer.process(input)

    parser = Parser.new
    parser.process(tokens)
  end

  # @param [Integer] input
  # @return [String]
  def generate_roman(input)
    generator = Generator.new
    generator.process(input)
  end

end
