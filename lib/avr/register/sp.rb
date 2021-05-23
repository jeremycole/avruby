# typed: strict
# frozen_string_literal: true

module AVR
  class SP < RegisterPair
    extend T::Sig

    sig do
      params(
        cpu: CPU,
        l_memory_byte: MemoryByte,
        h_memory_byte: MemoryByte,
        initial_value: Integer
      ).void
    end
    def initialize(cpu, l_memory_byte, h_memory_byte, initial_value)
      super(
        cpu,
        MemoryByteRegister.new(cpu, "SPL", l_memory_byte),
        MemoryByteRegister.new(cpu, "SPH", h_memory_byte),
        "SP"
      )
      self.value = initial_value
    end

    sig { params(offset: Integer).returns(Integer) }
    def adjust(offset)
      self.value += offset
    end

    sig { params(by: Integer).returns(Integer) }
    def decrement(by = 1)
      adjust(-by)
    end

    sig { params(by: Integer).returns(Integer) }
    def increment(by = 1)
      adjust(+by)
    end
  end
end
