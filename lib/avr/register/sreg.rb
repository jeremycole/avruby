# typed: true
# frozen_string_literal: true

module AVR
  class SREG < MemoryByteRegisterWithNamedBits
    STATUS_BITS = T.let([:C, :Z, :N, :V, :S, :H, :T, :I].freeze, T::Array[Symbol])

    def initialize(cpu)
      super(cpu, "SREG", cpu.sram[cpu.device.register_memory_map[:SREG]], STATUS_BITS)
    end
  end
end
