module AVR
  class SRAM < AVR::Memory
    def initialize(cpu, size)
      super(cpu, "SRAM", size, 0)
    end
  end
end