# typed: true
# frozen_string_literal: true

module AVR
  class SRAM < Memory
    def initialize(size)
      super('SRAM', size, 0)
    end
  end
end
