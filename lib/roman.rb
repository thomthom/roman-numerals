class RomanNumeral < Numeric

  attr_reader :decimal
  attr_reader :roman

  # @param [Integer, String] input
  def initialize(input)
    if input.is_a?(Integer)
      @decimal = input
      @roman = generate_roman(input)
    elsif input.is_a?(String)
      adjusted = input.upcase
      @decimal = parse_roman(adjusted).freeze
      @roman = adjusted
    else
      raise TypeError, "expected Integer or String, got #{input.class}"
    end
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
    else
      nil
    end
  end

  # @return [Integer]
  def to_i
    @decimal
  end
  alias to_int to_i

  # @param [Numeric] other
  # @return [Array(Numeric, RomanNumeral)]
  def coerce(other)
    # > Inheriting classes should also implement arithmetic operator
    # > methods (+, -, * and /) and the <=> operator (see Comparable).
    # https://ruby-doc.org/core-2.7.2/Numeric.html
    case other
    when Integer
      # Note: The docs indicate that this should be [self.class.new(other), self],
      # but that would mean Integer + RomanNumeral returns RomanNumeral.
      # This seems wrong (?). Seems that Integer + RomanNumeral should return Integer.
      # And RomanNumeral + Integer should return RomanNumeral.
      [to_i, other]
    else
      raise TypeError, "unable to coerce to #{other.class}"
    end
  end

  # @return [String]
  def to_s
    @roman
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
    if (1..3).include?(digit)
      # 1 => C
      # 2 => CC
      # 3 => CCC
      set.this * digit
    elsif digit == 4
      # 4 => CD
      "#{set.this}#{set.half}"
    elsif digit == 5
      # 5 => V
      set.half
    elsif (6..8).include?(digit)
      # 6 => DC
      # 7 => DCC
      # 8 => DCCC
      count = digit - 5
      "#{set.half}#{(set.this * count) }"
    elsif digit == 9
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
    raise RangeError, "integer too large" if input >= 4000 # TODO: Figure out how to represent larger numbers

    output = ''
    string = input.to_s
    string.each_char.with_index { |token, i|
      # Position from the right. (Base 1)
      position = string.size - i
      output << digit_to_roman(position, token.to_i)
    }
    output
  end

end
