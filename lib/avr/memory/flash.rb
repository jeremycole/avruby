module AVR
  class Flash < AVR::Memory
    def initialize(size)
      super("Flash", size, 0xff)
    end
  end
end
