# frozen_string_literal: true

require_relative 'token'

class RomanNumeral < Numeric

  # @private
  # Generates sequence of Roman numerals from the given input string.
  class Lexer

    # A map of the Roman numerals and their decimal values.
    ROMAN_TOKENS = {
      'M̅' => Token.new('M̅', 1_000_000),
      'D̅' => Token.new('D̅', 500_000),
      'C̅' => Token.new('C̅', 100_000),
      'L̅' => Token.new('L̅', 50_000),
      'X̅' => Token.new('X̅', 10_000),
      'V̅' => Token.new('V̅', 5_000),
      'I̅' => Token.new('I̅', 1_000),
      'M' => Token.new('M', 1_000),
      'D' => Token.new('D', 500),
      'C' => Token.new('C', 100),
      'L' => Token.new('L', 50),
      'X' => Token.new('X', 10),
      'V' => Token.new('V', 5),
      'I' => Token.new('I', 1),
      'N' => Token.new('N', 0),
    }.freeze
    private_constant :ROMAN_TOKENS

    # Prefix `_` before a numeral to multiply it by `1000`.
    # This is an ASCII alternative to the unicode notation.
    MEGA_MODIFIER_PREFIX = '_'
    private_constant :MEGA_MODIFIER_PREFIX

    # A Unicode postfix modifier multiplying the preceding
    # numeral by `1000`.
    MEGA_MODIFIER_POSTFIX = "\u0305"
    private_constant :MEGA_MODIFIER_POSTFIX

    # List of numerals that can be modified by the thousand modifiers.
    MODIFIABLE_NUMERALS = 'MDCLXVI'
    private_constant :MODIFIABLE_NUMERALS

    # @param [String] input
    # @return [Array<Token>]
    def process(input)
      raise ArgumentError, 'invalid numeral: empty string' if input.empty?

      tokens = []
      mega = false
      input.each_char.with_index { |char, i|
        # Account for ASCII modifier to the numerals.
        if mega && !MODIFIABLE_NUMERALS.include?(char)
          raise ArgumentError, "unexpected char after MEGA_MODIFIER_PREFIX: #{char}"
        end

        if char == MEGA_MODIFIER_PREFIX
          mega = true
          next
        end

        # Account for possible Combining Overline diacritics.
        # https://en.wikipedia.org/wiki/Combining_character
        next if char == MEGA_MODIFIER_POSTFIX

        buffer = char

        # Look ahead to see if there's an overline, indicating multiplication by 1000.
        if input[i + 1] == MEGA_MODIFIER_POSTFIX
          buffer = input[i, 2]
          # Can't combine ASCII notation and Unicode chars.
          raise ArgumentError, "unexpected char after MEGA_MODIFIER_PREFIX: #{char}" if mega
        end

        # Convert the ASCII notation to Unicode notation.
        buffer = "#{char}#{MEGA_MODIFIER_POSTFIX}" if mega

        token = ROMAN_TOKENS[buffer]
        raise ArgumentError, "invalid numeral: #{buffer}" if token.nil?

        # Reset the MEGA state now that we have the full char.
        mega = false

        tokens << token
      }
      tokens
    end

  end

end
