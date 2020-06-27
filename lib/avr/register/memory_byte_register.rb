# typed: true
# frozen_string_literal: true

module AVR
  class MemoryByteRegister < Register
    attr_reader :memory_byte

    def initialize(cpu, name, memory_byte)
      super(cpu, name)
      @memory_byte = memory_byte
    end

    def value
      memory_byte.value
    end

    def value=(new_value)
      memory_byte.value = new_value
    end
  end
end
