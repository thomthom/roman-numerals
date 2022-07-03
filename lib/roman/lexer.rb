# frozen_string_literal: true

require 'roman/tokens'

class RomanNumeral < Numeric

  # @private
  # Generates sequence of Roman numerals from the given input string.
  class Lexer

    # Prefix `_` before a numeral to multiply it by `1000`.
    # This is an ASCII alternative to the unicode notation.
    MEGA_MODIFIER_PREFIX = '_'
    private_constant :MEGA_MODIFIER_PREFIX

    # A Unicode postfix modifier multiplying the preceding
    # numeral by `1000`.
    MEGA_MODIFIER_POSTFIX = "\u0305"
    private_constant :MEGA_MODIFIER_POSTFIX

    # List of numerals that can be modified by the thousand modifiers.
    MODIFIABLE_TOKENS = 'MDCLXVI'
    private_constant :MODIFIABLE_TOKENS

    # @param [String] input
    # @return [Array<String>]
    def process(input)
      raise ArgumentError, 'invalid numeral: empty string' if input.empty?

      tokens = []
      mega = false
      input.each_char.with_index { |char, i|
        # Account for ASCII modifier to the numerals.
        if mega && !MODIFIABLE_TOKENS.include?(char)
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
        raise ArgumentError, "invalid numeral: #{buffer}" unless ROMAN_TOKENS.include?(char)

        # Reset the MEGA state now that we have the full char.
        mega = false

        tokens << buffer
      }
      tokens
    end

  end

end
