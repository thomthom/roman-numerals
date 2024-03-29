# frozen_string_literal: true

class RomanNumeral < Numeric

  # @private
  # Parses a sequence of Roman numerals into decimal representations.
  class Parser

    # @param [Array<Token>] tokens
    # @return [Integer]
    def process(tokens)
      sum = 0
      previous_value = 0
      chuck_sum = 0
      tokens.each { |token|
        # Read the characters in chunks. Each chunk consists of the same token.
        # Add up the sum for the chunk and compare against the previous token
        # chunk whether to add or subtract to the total sum.
        value = token.value
        if value == previous_value
          chuck_sum += value
        else
          if value > previous_value && previous_value > 0
            sum -= chuck_sum
          else
            sum += chuck_sum
          end
          chuck_sum = value
        end
        previous_value = value
      }
      sum + chuck_sum
    end

  end

end
