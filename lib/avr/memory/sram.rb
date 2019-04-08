module AVR
  class SRAM < AVR::Memory
    def initialize(size)
      super("SRAM", size, 0)
    end
  end
end