# typed: strict
# frozen_string_literal: true

module AVR
  class Device
    extend T::Sig
    extend T::Helpers
    abstract!

    sig { abstract.returns(Integer) }
    def sram_size; end

    sig { abstract.returns(Integer) }
    def flash_size; end

    sig { abstract.returns(Integer) }
    def eeprom_size; end

    sig { abstract.returns(T::Hash[Symbol, Integer]) }
    def data_memory_map; end

    sig { abstract.returns(Integer) }
    def register_start; end

    sig { abstract.returns(Integer) }
    def register_count; end

    sig { abstract.returns(T::Hash[Symbol, T::Array[T.nilable(Symbol)]]) }
    def register_bit_names_map; end

    sig { abstract.returns(T::Hash[Symbol, T::Hash[Symbol, Integer]]) }
    def word_register_map; end

    sig { abstract.returns(Integer) }
    def io_register_start; end

    sig { abstract.returns(Integer) }
    def io_register_count; end

    sig { abstract.returns(Integer) }
    def ext_io_register_start; end

    sig { abstract.returns(Integer) }
    def ext_io_register_count; end

    sig { abstract.returns(Integer) }
    def ram_start; end

    sig { abstract.returns(Integer) }
    def ram_end; end

    sig { abstract.returns(T::Hash[Symbol, Integer]) }
    def interrupt_vector_map; end

    sig { abstract.returns(T::Hash[Symbol, T::Hash[Symbol, Integer]]) }
    def port_map; end

    sig { returns(T::Hash[Integer, Symbol]) }
    def data_memory_map_by_address
      @data_memory_map_by_address ||= data_memory_map.each_with_object({}) do |(n, a), h|
        h[a] = n unless n =~ /^_/
      end
    end

    sig { returns(T::Array[T.nilable(Symbol)]) }
    def io_registers
      @io_registers ||= (0...io_register_count).map do |i|
        data_memory_map_by_address[io_register_start + i]
      end
    end

    sig { params(port: T.any(Symbol, String)).returns(T::Hash[Symbol, Integer]) }
    def standard_port(port)
      {
        pin: data_memory_map["PIN#{port}".to_sym],
        ddr: data_memory_map["DDR#{port}".to_sym],
        port: data_memory_map["PORT#{port}".to_sym],
      }
    end

    sig do
      params(
        ports: T::Array[T.any(Symbol, String)]
      ).returns(T::Hash[Symbol, T::Hash[Symbol, Integer]])
    end
    def standard_ports(ports)
      ports.each_with_object({}) { |m, h| h[m] = standard_port(m) }
    end

    sig { params(interrupts: T::Array[T.any(Symbol, String)]).returns(T::Hash[Symbol, Integer]) }
    def sequential_interrupt_vectors(interrupts)
      interrupts.each_with_index.each_with_object({}) { |(name, i), h| h[name.to_sym] = i * 2 }
    end

    sig { returns(CPU) }
    attr_reader :cpu

    sig { returns(Clock) }
    attr_reader :system_clock

    sig { returns(Oscillator) }
    attr_reader :oscillator

    sig { returns(Flash) }
    attr_reader :flash

    sig { returns(EEPROM) }
    attr_reader :eeprom

    sig { void }
    def initialize
      @cpu = T.let(CPU.new(self), CPU)
      @flash = T.let(Flash.new(flash_size), Flash)
      @eeprom = T.let(EEPROM.new(eeprom_size, cpu), EEPROM)

      @system_clock = T.let(Clock.new('system'), Clock)
      @system_clock.push_sink(cpu.clock)

      @oscillator = T.let(Oscillator.new('oscillator'), Oscillator)
      @oscillator.push_sink(system_clock)

      @data_memory_map_by_address = T.let(nil, T.nilable(T::Hash[Integer, Symbol]))
      @io_registers = T.let(nil, T.nilable(T::Array[T.nilable(Symbol)]))
    end

    sig { void }
    def trace_cpu
      cpu.trace do |instruction|
        puts '*** %20s: %04x %s' % [
          'INSTRUCTION TRACE',
          cpu.pc * 2,
          instruction,
        ]
      end
    end

    sig { void }
    def trace_registers
      register_addresses = {}
      cpu.registers.registers.each do |_name, register|
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
      cpu.sram.watch do |memory_byte, old_value, _new_value|
        registers = register_addresses[memory_byte.address]
        registers&.each do |register|
          puts '*** %20s: %12s: %4s -> %4s' % [
            'REGISTER TRACE',
            register.name,
            register.is_a?(MemoryByteRegister) ? register.format % old_value : '',
            register.format % register.value,
          ]
        end
      end
    end

    sig { void }
    def trace_sreg
      cpu.sram.watch do |memory_byte, old_value, new_value|
        if memory_byte.address == cpu.sreg.memory_byte.address
          puts '*** %20s: %s' % [
            'SREG TRACE',
            cpu.sreg.diff_values(old_value, new_value),
          ]
        end
      end
    end

    sig { void }
    def trace_sram
      cpu.sram.watch do |memory_byte, old_value, new_value|
        puts '*** %20s: %12s: %4s -> %4s' % [
          'MEMORY TRACE',
          '%s[%04x]' % [memory_byte.memory.name, memory_byte.address],
          memory_byte.format % old_value,
          memory_byte.format % new_value,
        ]
      end
    end

    sig { void }
    def trace_flash
      flash.watch do |memory_byte, old_value, new_value|
        puts '*** %20s: %12s: %4s -> %4s' % [
          'MEMORY TRACE',
          '%s[%04x]' % [memory_byte.memory.name, memory_byte.address],
          memory_byte.format % old_value,
          memory_byte.format % new_value,
        ]
      end
    end

    sig { void }
    def trace_eeprom
      eeprom.watch do |memory_byte, old_value, new_value|
        puts '*** %20s: %12s: %4s -> %4s' % [
          'MEMORY TRACE',
          '%s[%04x]' % [memory_byte.memory.name, memory_byte.address],
          memory_byte.format % old_value,
          memory_byte.format % new_value,
        ]
      end
    end

    sig { void }
    def trace_status_pre_tick
      oscillator.unshift_sink(
        Clock::Sink.new('pre-execution status') do
          puts
          puts
          puts 'PRE-EXECUTION STATUS'
          puts '********************'
          cpu.print_status
        end
      )
    end

    sig { void }
    def trace_status_post_tick
      oscillator.push_sink(
        Clock::Sink.new('post-execution status') do
          puts
          puts 'POST-EXECUTION STATUS'
          puts '*********************'
          cpu.print_status
        end
      )
    end

    sig { void }
    def trace_all
      trace_cpu
      trace_sram
      trace_flash
      trace_eeprom
      trace_sreg
      trace_registers
      trace_status_pre_tick
      trace_status_post_tick
    end
  end
end
