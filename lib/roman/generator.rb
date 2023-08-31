# frozen_string_literal: true

class RomanNumeral < Numeric

  # @private
  # Generates Roman numerals from decimal input.
  class Generator

    # @param [Integer] input
    # @raise [RangeError] when the input is outside the range of what can be converted to roman numerals.
    def self.check_range(input)
      raise RangeError, "integer out of range: #{input}" unless (0...10_000_000).include?(input)
    end

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

    # Maps each decimal position to the set of Roman numerals needed to
    # represent the decimal digit.
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

    # @param [Integer] input
    # @return [String]
    def process(input)
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
      self.class.check_range(input)

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

    private

    # @param [Integer] position
    # @param [Integer] digit
    # @return [String]
    def digit_to_roman(position, digit)
      raise ArgumentError, "digit out of bounds: #{digit}" unless (0..9).include?(digit)

      set = NUMERAL_SETS[position]
      raise "invalid numeral set: #{position}" if set.nil?

      # Edge case for the upper bound range supported decimal.
      if position == NUMERAL_SETS.size
        return set.this * digit
      end

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
        # 0 => ''
        ''
      end
    end

  end

end
