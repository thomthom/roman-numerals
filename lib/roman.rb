# frozen_string_literal: true

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

  # @return [String]
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

  ROMAN_TOKENS = {
    'M' => 1000,
    'D' => 500,
    'C' => 100,
    'L' => 50,
    'X' => 10,
    'V' => 5,
    'I' => 1,
  }.freeze

  private_constant :ROMAN_TOKENS

  # @param [String] input
  # @return [Integer]
  def parse_roman(input)
    sum = 0
    previous_value = 0
    buffer_sum = 0
    input.each_char { |token|
      raise ArgumentError, "invalid numeral: #{token}" unless ROMAN_TOKENS.include?(token)

      value = ROMAN_TOKENS[token]
      if value == previous_value
        buffer_sum += value
      else
        if value > previous_value && previous_value > 0
          sum -= buffer_sum
        else
          sum += buffer_sum
        end
        buffer_sum = value
      end
      previous_value = value
    }
    sum + buffer_sum
  end

  NumeralSet = Struct.new(:next, :half, :this)

  NUMERAL_SETS = {
    4 => NumeralSet.new(nil, nil, 'M'),
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
      "#{set.this}#{set.half}"
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
      "#{set.this}#{set.next}"
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
    # _M = 1 000 000
    # _D =   500 000
    # _C =   100 000
    # _L =    50 000
    # _X =    10 000
    # _V =     5 000
    # _I =     1 000
    #
    # Combining Overline Unicode Character:
    # M\u0305 => M̅
    # C\u0305 => C̅
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
  # @raises [RangeError] when the input is outside the range of what can be converted to roman numerals.
  def check_range(input)
    raise RangeError, "integer too large: #{input}" unless (0...4000).include?(input)
  end

end
