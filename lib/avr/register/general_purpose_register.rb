# typed: strict
# frozen_string_literal: true

module AVR
  class GeneralPurposeRegister < MemoryByteRegister
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :number

    sig { params(cpu: CPU, number: Integer, memory_byte: MemoryByte).void }
    def initialize(cpu, number, memory_byte)
      super(cpu, :"r#{number}", memory_byte)

      @number = number
    end
  end
end
