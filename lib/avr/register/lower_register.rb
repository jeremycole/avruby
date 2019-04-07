module AVR
  class LowerRegister < MemoryByteRegister
    def initialize(cpu, name, memory_byte)
      super(cpu, name, memory_byte)
    end
  end
end