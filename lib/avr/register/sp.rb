# typed: true
# frozen_string_literal: true

module AVR
  class SP < RegisterPair
    def initialize(cpu, l_memory_byte, h_memory_byte, initial_value)
      super(
        cpu,
        'SP',
        MemoryByteRegister.new(cpu, 'SPL', l_memory_byte),
        MemoryByteRegister.new(cpu, 'SPH', h_memory_byte)
      )
      self.value = initial_value
    end

    def adjust(offset)
      self.value += offset
    end

    def decrement(by = 1)
      adjust(-by)
    end

    def increment(by = 1)
      adjust(+by)
    end
  end
end
