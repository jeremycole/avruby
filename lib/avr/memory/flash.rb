# typed: strict
# frozen_string_literal: true

module AVR
  class Flash < Memory
    extend T::Sig

    sig { params(size: Integer).void }
    def initialize(size)
      super('Flash', size, 0xff)
    end
  end
end
