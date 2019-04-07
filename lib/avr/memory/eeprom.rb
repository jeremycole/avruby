module AVR
  class EEPROM < AVR::Memory
    def initialize(cpu, size)
      super(cpu, "EEPROM", size, 0xff)
    end
  end
end