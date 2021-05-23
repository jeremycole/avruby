# typed: strict
# frozen_string_literal: true

module AVR
  class RegisterWithBitNumber < Value
    extend T::Sig

    sig { returns(MemoryByteRegister) }
    attr_reader :register

    sig { returns(Integer) }
    attr_reader :bit_number

    sig { returns(Integer) }
    attr_reader :bit_mask

    sig { params(register: MemoryByteRegister, bit_number: Integer).void }
    def initialize(register, bit_number)
      @register = register
      @bit_number = bit_number
      @bit_mask = T.let(1 << bit_number, Integer)
      super()
    end

    sig { returns(Integer) }
    def value
      (register.value & bit_mask) >> bit_number
    end

    sig { params(new_value: Integer).void }
    def value=(new_value)
      register.value |= (new_value << bit_number) & bit_mask
    end

    sig { returns(String) }
    def name
      "#{register.name}.#{bit_number}"
    end
  end
end
