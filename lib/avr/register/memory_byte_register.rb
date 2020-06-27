# typed: strict
# frozen_string_literal: true

module AVR
  class MemoryByteRegister < Register
    extend T::Sig

    sig { returns(MemoryByte) }
    attr_reader :memory_byte

    sig { params(cpu: CPU, name: T.any(Symbol, String), memory_byte: MemoryByte).void }
    def initialize(cpu, name, memory_byte)
      super(cpu, name)
      @memory_byte = memory_byte
    end

    sig { returns(Integer) }
    def value
      memory_byte.value
    end

    sig { params(new_value: Integer).void }
    def value=(new_value)
      memory_byte.value = new_value
    end
  end
end
