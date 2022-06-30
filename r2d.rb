# Roman Numerals to Decimals
#
# ruby r2d.rb MCMXXCIII => 1983
# ruby r2d.rb MCMLXXXIII => 1983
# ruby r2d.rb MCMXXCIIV => 1983

class RomanNumeralParser

  TOKENS = {
    'M' => 1000,
    'D' => 500,
    'C' => 100,
    'L' => 50,
    'X' => 10,
    'V' => 5,
    'I' => 1,
  }

  def parse(input)
    sum = 0
    previous_value = 0
    buffer_sum = 0
    input.each_char { |token|
      raise "invalid numeral: #{token}" unless TOKENS.include?(token)

      value = TOKENS[token]
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

input = ARGV[0].upcase
parser = RomanNumeralParser.new
decimals = parser.parse(input)

puts "#{input} => #{decimals}"
