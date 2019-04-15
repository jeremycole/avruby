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

    def trace_cpu
      cpu.trace do |instruction|
        puts "*** %20s: %s ***" % [
          "INSTRUCTION TRACE",
          instruction,
        ]
      end
    end

    def trace_registers
      register_addresses = {}
      cpu.registers.registers.each do |name, register|
        case register
        when MemoryByteRegister
          register_addresses[register.memory_byte.address] ||= []
          register_addresses[register.memory_byte.address] << register
        when RegisterPair
          register_addresses[register.l.memory_byte.address] ||= []
          register_addresses[register.l.memory_byte.address] << register
          register_addresses[register.h.memory_byte.address] ||= []
          register_addresses[register.h.memory_byte.address] << register
        end
      end
      cpu.sram.watch do |memory_byte, old_value, new_value|
        registers = register_addresses[memory_byte.address]
        if registers
          registers.each do |register|
            puts "*** %20s: %12s: %4s -> %4s ***" % [
              "REGISTER TRACE",
              register.name,
              register.is_a?(MemoryByteRegister) ? register.format % old_value : "",
              register.format % register.value,
            ]
          end
        end
      end
    end

    def trace_sreg
      cpu.sram.watch do |memory_byte, old_value, new_value|
        if memory_byte.address == cpu.sreg.memory_byte.address
          puts "*** %20s: %s" % [
            "SREG TRACE",
            cpu.sreg.diff_values(old_value, new_value),
          ]
        end
      end
    end

    def trace_sram
      cpu.sram.watch do |memory_byte, old_value, new_value|
        puts "*** %20s: %12s: %4s -> %4s ***" % [
          "MEMORY TRACE",
          "%s[%04x]" % [memory_byte.memory.name, memory_byte.address],
          memory_byte.format % old_value,
          memory_byte.format % new_value,
        ]
      end
    end

    def trace_status_pre_tick
      oscillator.unshift_sink(AVR::Clock::Sink.new("pre-execution status") {
        puts
        puts
        puts "PRE-EXECUTION STATUS"
        puts "********************"
        cpu.print_status
      })
    end

    def trace_status_post_tick
      oscillator.push_sink(AVR::Clock::Sink.new("post-execution status") {
        puts
        puts "POST-EXECUTION STATUS"
        puts "*********************"
        cpu.print_status
      })
    end

    def trace_all
      trace_cpu
      trace_sram
      trace_sreg
      trace_registers
      trace_status_pre_tick
      trace_status_post_tick
    end
  end
end

require "avr/device/atmel_atmega328p"