# frozen_string_literal: true

require 'roman/tokens'

class RomanNumeral < Numeric

  # @private
  class Parser

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
