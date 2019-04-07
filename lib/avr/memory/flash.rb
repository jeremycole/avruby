module AVR
  class Flash < AVR::Memory
    def initialize(cpu, size)
      super(cpu, "Flash", size, 0xff)
    end
  end
end
