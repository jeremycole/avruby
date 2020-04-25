# frozen_string_literal: true

module AVR
  class SREG < MemoryByteRegisterWithNamedBits
    STATUS_BITS = %i[C Z N V S H T I].freeze

    def initialize(cpu)
      super(cpu, 'SREG', cpu.sram.memory[cpu.device.data_memory_map[:SREG]], STATUS_BITS)
    end
  end
end
