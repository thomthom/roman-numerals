# Roman Numerals to Decimals
#
# ruby roman.rb MCMXXCIII => 1983
# ruby roman.rb MCMLXXXIII => 1983
# ruby roman.rb MCMXXCIIV => 1983
#
# Decimals to  Roman Numerals
#
# ruby roman.rb 1983 => MCMXXCIIV

class RomanNumeral

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
      raise TypeError, "expected Integer or String, go #{input.class}"
    end
  end

  def to_i
    @decimal
  end

  def to_s
    @roman
  end

  private

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

  # DECIMAL_TOKENS = {
  #   4 => 'M',
  #   # 4 => 'D', 
  #   3 => 'C',
  #   # 4 => 'L',
  #   2 => 'X',
  #   # 4 => 'V',
  #   1 => 'I',
  # }.freeze

  NumeralSet = Struct.new(:next, :half, :this)

  NUMERAL_SETS = {
    4 => NumeralSet.new(nil, nil, 'M'),
    3 => NumeralSet.new('M', 'D', 'C'),
    2 => NumeralSet.new('C', 'L', 'X'),
    1 => NumeralSet.new('X', 'V', 'I'),
    0 => NumeralSet.new('I', nil, nil),
  }.freeze

  private_constant :NUMERAL_SETS

  # @param [Integer] position
  # @param [Integer] digit
  # @return [String]
  def digit_to_roman(position, digit)
    raise ArgumentError, "digit out of bounds: #{digit}" unless (0..9).include?(digit)

    # NUMERAL_SETS[position] * digit
    set = NUMERAL_SETS[position]
    raise "invalid numeral set: #{position}" if set.nil?

    # --------------------------------------------------------------------------

    # 1984
    # ^
    # +--- => M

    # 1984
    #  ^
    #  +-- => CM

    # 1984
    #   ^
    #   +-- => XXC

    # 1984
    #    ^
    #    +-- => IV

    # --------------------------------------------------------------------------

    # 1984
    #  ^
    #  +-- => CM

    # MDC

    #  9 => CM
    #  8 => CCM
    #  7 => DCC
    #  6 => DC
    #  5 => D
    #  4 => CD
    #  3 => CCD
    #  2 => CC
    #  1 => C
    #  0 => ''

    # --------------------------------------------------------------------------

    # Examples in position 3 (centi)
    if (1..2).include?(digit)
      # 1 => C
      # 2 => CC
      set.this * digit
    elsif (3..4).include?(digit)
      # 3 => CCD
      # 4 => CD
      count = 5 - digit
      (set.this * count) << set.half
    elsif digit == 5
      # 5 => V
      set.half
    elsif (6..7).include?(digit)
      # 6 => DC
      # 7 => DCC
      count = digit - 5
      (set.half * count) << set.this
    elsif (8..9).include?(digit)
      # 8 => CCM
      # 9 => CM
      count = 10 - digit
      (set.this * count) << set.next
    else
      # 0 -> ''
      ''
    end
  end

  # @param [Integer] input
  # @return [String]
  def generate_roman(input)
    raise "integer too large" if input > 10000 # TODO: Figure out how to represent larger numbers

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

input = ARGV[0]
integer_pattern = /\A\s*\d+\s*\z/
input = input.to_i if integer_pattern.match?(input)

numeral = RomanNumeral.new(input)

puts "#{numeral.roman} => #{numeral.decimal}"
