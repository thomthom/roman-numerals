# frozen_string_literal: true

require 'roman/lexer'
require 'roman/parser'

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
      check_range(input)
      @decimal = input
      @roman = nil # Lazy-generated. (See #roman)
    when String
      adjusted = input.upcase
      @decimal = parse_roman(adjusted)
      @roman = adjusted.freeze
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

  # @!parse public

  # @private
  #
  # Defines the relationship of Roman numeral tokens when converted from decimals.
  #
  # @!attribute [r] next
  #   @return [String, nil] The token for the next decimal place. For example:
  #     If the current token is `X` (`10`), then the next decimal token is `C` (`100`).
  #
  # @!attribute [r] half
  #   @return [String, nil] The token for the numeral halfway to the next decimal place. For example:
  #     If the current token is `X` (`10`), then the half decimal token is `D` (`50`).
  #
  # @!attribute [r] this
  #   @return [String, nil] The token for the current decimal place. For example:
  #     If the value is `20` and the current decimal place is `2`, then `this`
  #     token is `X` (`10`).
  #
  # @!attribute [r] down
  #   @return [String, nil] There is an edge-case for `4000` and `9000` where the
  #     numeral will have to be adjusted in order to yield a consistent overline
  #     notation. This is declared via this optional `down` property.
  #     This is the token to substitute when `1` is subtracted from the current
  #     decimal position. For instance: `4` (`I̅V̅`) or `9` (`I̅X̅`) at the fourth
  #     decimal position when we switch to overline notation.
  #
  NumeralSet = Struct.new(:next, :half, :this, :down)

  # @!parse private

  NUMERAL_SETS = {
    7 => NumeralSet.new(nil, nil, 'M̅'),
    6 => NumeralSet.new('M̅', 'D̅', 'C̅'),
    5 => NumeralSet.new('C̅', 'L̅', 'X̅'),
    4 => NumeralSet.new('X̅', 'V̅', 'M', 'I̅'),
    3 => NumeralSet.new('M', 'D', 'C'),
    2 => NumeralSet.new('C', 'L', 'X'),
    1 => NumeralSet.new('X', 'V', 'I'),
  }.freeze

  private_constant :NUMERAL_SETS

  # @param [Integer] position
  # @param [Integer] digit
  # @return [String]
  def digit_to_roman(position, digit)
    raise ArgumentError, "digit out of bounds: #{digit}" unless (0..9).include?(digit)

    set = NUMERAL_SETS[position]
    raise "invalid numeral set: #{position}" if set.nil?

    # https://en.wikipedia.org/wiki/Roman_numerals#Standard_form
    #
    #  0 => ''
    #  1 => C
    #  2 => CC
    #  3 => CCC
    #  4 => CD
    #  5 => D
    #  6 => DC
    #  7 => DCC
    #  8 => DCCC
    #  9 => CM

    # Examples in position 3 (centi)
    case digit
    when 1..3
      # 1 => C
      # 2 => CC
      # 3 => CCC
      set.this * digit
    when 4
      # 4 => CD
      this = set.down || set.this
      "#{this}#{set.half}"
    when 5
      # 5 => V
      set.half
    when 6..8
      # 6 => DC
      # 7 => DCC
      # 8 => DCCC
      count = digit - 5
      "#{set.half}#{set.this * count}"
    when 9
      # 9 => CM
      this = set.down || set.this
      "#{this}#{set.next}"
    else
      # 0 -> ''
      ''
    end
  end

  # @param [Integer] input
  # @return [String]
  def generate_roman(input)
    # https://en.wikipedia.org/wiki/Roman_numerals#Large_numbers
    #
    # Apostrophus:
    # https://en.wikipedia.org/wiki/Roman_numerals#Apostrophus
    #
    # Vinculum:
    # https://en.wikipedia.org/wiki/Roman_numerals#Vinculum
    #
    #   To convert Roman numerals greater than 3,999 use the table below for converter inputs.
    #   Use a leading underline character to input Roman numerals with an overline. A line over a
    #   Roman numeral means it is multiplied by 1,000.
    #
    # _M = 1 000 000 - M̅
    # _D =   500 000 - D̅
    # _C =   100 000 - C̅
    # _L =    50 000 - L̅
    # _X =    10 000 - X̅
    # _V =     5 000 - V̅
    # _I =     1 000 - I̅
    #
    # Combining Overline Unicode Character:
    # M\u0305 => M̅
    # D\u0305 => D̅
    # C\u0305 => C̅
    # L\u0305 => L̅
    # X\u0305 => X̅
    # V\u0305 => V̅
    # I\u0305 => I̅
    #
    # https://stackoverflow.com/questions/41664207/adding-the-combining-overline-unicode-character
    check_range(input)

    # It's less clear how zero was represented. Some indication that `nulla`, others `N`.
    # https://en.wikipedia.org/wiki/Roman_numerals#Zero
    return +'N' if input == 0

    output = +''
    string = input.to_s
    string.each_char.with_index { |token, i|
      # Position from the right. (Base 1)
      position = string.size - i
      output << digit_to_roman(position, token.to_i)
    }
    output
  end

  # @param [Integer] input
  # @raise [RangeError] when the input is outside the range of what can be converted to roman numerals.
  def check_range(input)
    raise RangeError, "integer out of range: #{input}" unless (0...4_000_000).include?(input)
  end

end
