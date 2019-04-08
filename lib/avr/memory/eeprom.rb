module AVR
  class EEPROM < AVR::Memory
    def initialize(size)
      super("EEPROM", size, 0xff)
    end
  end
end