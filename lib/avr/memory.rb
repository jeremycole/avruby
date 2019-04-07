require "avr/memory/memory_byte"

module AVR
  class Memory
    attr_reader :cpu
    attr_reader :name
    attr_reader :size
    attr_reader :memory

    def initialize(cpu, name, size, value=0)
      @cpu = cpu
      @name = name
      @size = size
      @memory = size.times.map { |address| MemoryByte.new(self, address, value) }
    end

    def inspect
      "#<#{self.class.name} size=#{size}>"
    end

    def word(address)
      byte_address = address << 1
      (memory[byte_address + 1].value << 8) | memory[byte_address].value
    end

    def load_from_intel_hex(filename)
      ihex = IntelHex.new(filename)
      ihex.each_byte do |address, byte|
        memory[address].value = byte
      end
      nil
    end
  end
end

require "avr/memory/sram"
require "avr/memory/eeprom"
require "avr/memory/flash"
