# typed: false
# frozen_string_literal: true

module AVR
  class CPU
    class DecodeError < RuntimeError; end

    extend T::Sig

    sig { returns(Device) }
    attr_reader :device

    sig { returns(Integer) }
    attr_accessor :pc

    sig { returns(Integer) }
    attr_accessor :next_pc

    sig { returns(Memory::SRAM) }
    attr_reader :sram

    sig { returns(Memory) }
    def data_address_space
      sram
    end

    sig { returns(RegisterFile) }
    attr_reader :registers

    sig { returns(Register) }
    def r0
      registers.fetch(:r0)
    end

    sig { params(value: Integer).void }
    def r0=(value)
      r0.value = value
    end

    sig { returns(Register) }
    def r1
      registers.fetch(:r1)
    end

    sig { params(value: Integer).void }
    def r1=(value)
      r1.value = value
    end

    sig { returns(Register) }
    def r1r0
      @r1r0 ||= RegisterPair.new(self, r1, r0)
    end

    sig { params(value: Integer).void }
    def r1r0=(value)
      r1r0.value = value
    end

    sig { returns(Register) }
    def X # rubocop:disable Naming/MethodName
      registers.fetch(:X)
    end

    sig { returns(Register) }
    def Y # rubocop:disable Naming/MethodName
      registers.fetch(:Y)
    end

    sig { returns(Register) }
    def Z # rubocop:disable Naming/MethodName
      registers.fetch(:Z)
    end

    sig { returns(RegisterFile) }
    attr_reader :io_registers

    sig { returns(Memory::Fuses) }
    def fuses
      device.fuses
    end

    # SREG uses metaprogramming that Sorbet doesn't understand
    # sig { returns(SREG) }
    sig { returns(T.untyped) }
    attr_reader :sreg

    sig { returns(SP) }
    attr_reader :sp

    sig { returns(OpcodeDecoder) }
    attr_reader :decoder

    sig { returns(T::Hash[Symbol, Port]) }
    attr_reader :ports

    sig { returns(Clock) }
    attr_reader :clock

    sig { returns(T.nilable(T.proc.params(arg0: Instruction).void)) }
    attr_reader :tracer

    sig { params(device: Device).void }
    def initialize(device)
      @device = device
      @pc = 0
      @next_pc = 0
      @sram = Memory::SRAM.new(device.ram_start + device.sram_size)

      @registers = RegisterFile.new(self)

      device.register_count.times do |n|
        registers.add(GeneralPurposeRegister.new(self, n, data_address_space[n]))
      end

      device.word_register_map.each do |name, map|
        registers.add(RegisterPair.new(self, @registers[map[:h]], @registers[map[:l]], name))
      end

      @io_registers = RegisterFile.new(self)
      (device.io_registers + device.ext_io_registers).each do |name|
        next unless name

        address = device.register_memory_map[name]
        next unless address

        bit_names = device.register_bit_names_map[name]
        if bit_names
          io_registers.add(MemoryByteRegisterWithNamedBits.new(self, name.to_s, data_address_space[address], bit_names))
        else
          io_registers.add(MemoryByteRegister.new(self, name.to_s, data_address_space[address]))
        end
      end

      @sreg = SREG.new(self)

      @sp = SP.new(
        self,
        data_address_space[device.register_memory_map[:SPH]],
        data_address_space[device.register_memory_map[:SPL]],
        device.ram_end
      )

      @decoder = OpcodeDecoder.new

      @ports = {}
      device.port_map.each do |name, addr|
        @ports[name] = Port.new(self, name, addr[:pin], addr[:ddr], addr[:port])
      end

      @clock = Clock.new("cpu")
      @clock.push_sink(Clock::Sink.new("cpu") { step })

      @tracer = nil
    end

    def notify_at_tick(tick, &block)
      clock.notify_at_tick(tick, Clock::Sink.new("notify #{block} at #{tick}", block.to_proc))
    end

    sig { params(block: T.nilable(T.proc.params(arg0: Instruction).void)).void }
    def trace(&block)
      @tracer = nil
      @tracer = block.to_proc if block_given?
    end

    sig { void }
    def print_status
      puts "Status:"
      puts format("%8s = %d", "Ticks", clock.ticks)
      puts format("%8s = %d opcodes", "Cache", decoder.cache.size)
      puts format("%8s = 0x%04x words", "PC", pc)
      puts format("%8s = 0x%04x bytes", "PC", pc * 2)
      puts format("%8s = 0x%04x (%d bytes used)", "SP", sp.value, device.ram_end - sp.value)
      puts format("%8s = 0x%02x [%s]", "SREG", sreg.value, sreg.bit_values)
      puts
      puts "Registers:"
      registers.print_status
      puts
      puts "IO Registers:"
      io_registers.print_status
      puts
      puts "IO Ports:"
      puts format("%4s  %s", "", Port::PINS.join(" "))
      ports.each do |name, port|
        puts format("%4s: %s", name, port.pin_states.join(" "))
      end
      puts
      puts "Next instruction:"
      begin
        puts "  #{peek}"
      rescue AVR::CPU::DecodeError => e
        puts "  [#{e}]"
      end
      puts
    end

    sig { void }
    def reset_to_clean_state
      registers.reset
      io_registers.reset
      sram.reset
      reset
      sp.value = device.ram_end
    end

    sig { void }
    def reset
      @pc = device.reset_address
      @next_pc = @pc
      sreg.reset
      reset_clkpr
    end

    sig { void }
    def reset_clkpr
      return unless io_registers.registers.key?("CLKPR")

      clkpr = io_registers.registers["CLKPR"]
      clkdiv8 = device.fuses.respond_to?(:ckdiv8?) && T.unsafe(device.fuses).ckdiv8?

      if clkpr.is_a?(MemoryByteRegisterWithNamedBits)
        clkpr.CLKPS0 = clkdiv8
        clkpr.CLKPS1 = clkdiv8
        clkpr.CLKPS2 = false
        clkpr.CLKPS3 = false
      else
        clkpr.value = (clkpr.value & ~0x0f) | (clkdiv8 ? 0x03 : 0x00)
      end
    end

    sig { returns(Integer) }
    def fetch
      word = device.flash.word(next_pc)
      @next_pc += 1
      word
    end

    sig { params(mnemonic: Symbol, args: T.untyped).returns(Instruction) }
    def instruction(mnemonic, *args)
      Instruction.new(self, mnemonic, args)
    end

    sig { params(name_or_vector_number: T.any(Symbol, Integer)).void }
    def interrupt(name_or_vector_number)
      sreg.I = false
      case name_or_vector_number
      when Integer
        address = name_or_vector_number * 2
      when Symbol
        address = device.interrupt_vector_map[name_or_vector_number]
      end

      instruction(:call, Value.new(address)).execute
    end

    sig { returns(Instruction) }
    def decode
      offset = next_pc
      word = fetch
      decoded_opcode = decoder.decode(word)
      unless decoded_opcode
        raise DecodeError,
          format("Unable to decode 0x%04x at offset 0x%04x words (0x%04x bytes)", word, offset, offset * 2)
      end

      decoded_opcode.opcode_definition.parse(
        self,
        decoded_opcode.opcode_definition,
        decoded_opcode.prepare_operands(self)
      )
    end

    sig { returns(Instruction) }
    def peek
      save_pc = pc
      save_next_pc = next_pc
      i = decode
      @pc = save_pc
      @next_pc = save_next_pc
      i
    end

    sig { void }
    def step
      i = decode
      @tracer&.call(i)
      begin
        i.execute
      rescue StandardError
        puts "*** Caught exception while executing #{i}, CPU status:"
        print_status
        raise
      end
    end
  end
end
