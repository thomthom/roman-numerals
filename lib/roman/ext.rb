# frozen_string_literal: true

require 'roman'

class String

  # @return [RomanNumeral]
  def roman
    RomanNumeral.new(self)
  end

end

class Integer

  # @return [RomanNumeral]
  def roman
    RomanNumeral.new(self)
  end

end
