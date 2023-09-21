# frozen_string_literal: true

require_relative '../roman'

# By requiring `roman/ext` the {String} class is extended with helpers for
# syntactic sugar for creating {RomanNumeral} instances.
class String

  # @example
  #   require 'roman/ext'
  #
  #   numeral = 'MCMLXXXIII'.roman
  #   numeral.to_s # => 'MCMLXXXIII'
  #   numeral.to_i # => 1983
  #
  # @return [RomanNumeral]
  def roman
    RomanNumeral.new(self)
  end

end

# By requiring `roman/ext` the {String} class is extended with helpers for
# syntactic sugar for creating {RomanNumeral} instances.
class Integer

  # @example
  #   require 'roman/ext'
  #
  #   numeral = 1983.roman
  #   numeral.to_s # => 'MCMLXXXIII'
  #   numeral.to_i # => 1983
  #
  # @return [RomanNumeral]
  def roman
    RomanNumeral.new(self)
  end

end
