module AVR
  class Device
    def sram_size; end
    def flash_size; end
    def eeprom_size; end

    def data_memory_map; end
    def register_start; end
    def register_count; end
    def io_register_start; end
    def io_register_count; end
    def ext_io_register_start; end
    def ext_io_register_count; end
    def ram_start; end
    def ram_end; end

    def data_memory_map_by_address
      @data_memory_map_by_address ||= data_memory_map.each_with_object({}) { |(n, a), h|
        h[a] = n unless n =~ /^_/
      }
    end

    def io_registers
      @io_registers ||= (0 ... io_register_count).map { |i|
        data_memory_map_by_address[io_register_start + i]
      }
    end

    attr_reader :cpu
    attr_reader :system_clock
    attr_reader :oscillator
    attr_reader :flash
    attr_reader :eeprom

    def initialize
      @flash = Flash.new(flash_size)
      @eeprom = EEPROM.new(eeprom_size)
      @cpu = CPU.new(self)
      @system_clock = Clock.new("system")
      @system_clock.push_sink(cpu.clock)
      @oscillator = Oscillator.new("oscillator")
      @oscillator.push_sink(system_clock)
    end
  end
end

require "avr/device/atmel_atmega328p"