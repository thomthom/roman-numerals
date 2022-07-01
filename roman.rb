# frozen_string_literal: true

# Roman Numerals to Decimals
#
# ruby roman.rb MCMLXXXIII
# => 1983
#
# Decimals to  Roman Numerals
#
# ruby roman.rb 1983
# => MCMLXXXIII

require_relative 'lib/roman'

if $PROGRAM_NAME == File.basename(__FILE__)
  input = ARGV[0]
  integer_pattern = /\A\s*\d+\s*\z/
  input = input.to_i if integer_pattern.match?(input)

  numeral = RomanNumeral.new(input)

  if input.is_a?(Integer)
    puts "#{numeral.decimal} => #{numeral.roman}"
  else
    puts "#{numeral.roman} => #{numeral.decimal}"
  end
end
