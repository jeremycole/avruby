# typed: strict
# frozen_string_literal: true

module AVR
  class RegisterWithNamedBit < Value
    extend T::Sig

    sig { returns(MemoryByteRegisterWithNamedBits) }
    attr_reader :register

    sig { returns(Symbol) }
    attr_reader :named_bit

    sig { params(register: MemoryByteRegisterWithNamedBits, named_bit: Symbol).void }
    def initialize(register, named_bit)
      @register = register
      @named_bit = named_bit
      super()
    end

    sig { returns(Integer) }
    def value
      register.fetch_bit(named_bit)
    end

    sig { params(new_value: Integer).void }
    def value=(new_value)
      register.send("#{named_bit}=".to_sym, new_value)
    end

    sig { returns(String) }
    def name
      "#{register.name}.#{named_bit}"
    end
  end
end
