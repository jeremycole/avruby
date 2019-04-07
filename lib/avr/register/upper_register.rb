module AVR
  class UpperRegister < MemoryByteRegister
    def initialize(cpu, name, memory_byte)
      super(cpu, name, memory_byte)
    end
  end
end