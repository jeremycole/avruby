# typed: strict
# frozen_string_literal: true

module AVR
  class SRAM < Memory
    extend T::Sig

    sig { params(size: Integer).void }
    def initialize(size)
      super('SRAM', size, 0)
    end
  end
end
