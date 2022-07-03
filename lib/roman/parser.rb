# frozen_string_literal: true

class RomanNumeral < Numeric

  # @private
  class Parser

    ROMAN_TOKENS = {
      'M̅' => 1_000_000,
      'D̅' => 500_000,
      'C̅' => 100_000,
      'L̅' => 50_000,
      'X̅' => 10_000,
      'V̅' => 5_000,
      'I̅' => 1_000,
      'M' => 1_000,
      'D' => 500,
      'C' => 100,
      'L' => 50,
      'X' => 10,
      'V' => 5,
      'I' => 1,
    }.freeze

    # @param [Array<String>] tokens
    # @return [Integer]
    def process(tokens)
      sum = 0
      previous_value = 0
      buffer_sum = 0
      tokens.each { |token|
        # Read the characters in chunks. Each chunk consists of the same token.
        # Add up the sum for the chunk and compare against the previous token
        # chunk whether to add or subtract to the total sum.
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

  end

end
