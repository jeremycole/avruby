# typed: true
# frozen_string_literal: true

module AVR
  class Flash < Memory
    def initialize(size)
      super('Flash', size, 0xff)
    end
  end
end
