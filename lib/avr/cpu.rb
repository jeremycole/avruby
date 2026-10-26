# typed: false
# frozen_string_literal: true

module AVR
  class CPU
    class DecodeError < RuntimeError; end

    extend T::Sig

    sig { returns(Device) }
    attr_reader :device

    sig { returns(PC) }
    attr_reader :pc

    sig { returns(PC) }
    attr_reader :next_pc

    sig { returns(Memory::MemoryByteBacked) }
    attr_reader :register_memory

    sig { returns(Memory::MemoryByteBacked) }
    attr_reader :io_register_memory

    sig { returns(Memory::MemoryByteBacked) }
    attr_reader :ext_io_register_memory

    sig { returns(Memory::SRAM) }
    attr_reader :sram

    sig { returns(Memory::AddressSpace) }
    attr_reader :data_address_space

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

    sig { returns(RegisterFile) }
    attr_reader :ext_io_registers

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
      @pc = PC.new(device.flash_size_in_words)
      @next_pc = PC.new(device.flash_size_in_words)

      @data_address_space = Memory::AddressSpace.new("Data Address Space", 0xffff)

      @register_memory = Memory::MemoryByteBacked.new("registers", device.register_count, 0)
      data_address_space.attach(@register_memory, 0)

      @registers = RegisterFile.new(self)

      device.register_count.times do |n|
        registers.add(GeneralPurposeRegister.new(self, n, data_address_space[n]))
      end

      device.word_register_map.each do |name, map|
        registers.add(RegisterPair.new(self, @registers[map[:h]], @registers[map[:l]], name))
      end

      @io_register_memory = Memory::MemoryByteBacked.new("io_registers", device.io_register_count, 0)
      data_address_space.attach(@io_register_memory, device.io_register_start)

      @ext_io_register_memory = Memory::MemoryByteBacked.new("ext_io_registers", device.ext_io_register_count, 0)
      data_address_space.attach(@ext_io_register_memory, device.ext_io_register_start)

      @io_registers = RegisterFile.new(self)
      @ext_io_registers = RegisterFile.new(self)

      {
        @io_registers => device.io_registers,
        @ext_io_registers => device.ext_io_registers,
      }.each do |register_file, names|
        names.each do |name|
          next unless name

          address = device.register_memory_map[name]
          next unless address

          bit_names = device.register_bit_names_map[name]
          if bit_names
            register_file.add(
              MemoryByteRegisterWithNamedBits.new(self, name.to_s, data_address_space[address], bit_names)
            )
          else
            register_file.add(MemoryByteRegister.new(self, name.to_s, data_address_space[address]))
          end
        end
      end

      @sreg = SREG.new(self)

      @sp = SP.new(
        self,
        data_address_space[device.register_memory_map[:SPH]],
        data_address_space[device.register_memory_map[:SPL]],
        device.ram_end
      )

      @sram = Memory::SRAM.new(device.sram_size)
      data_address_space.attach(@sram, device.ram_start)

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
      puts format("%8s = 0x%04x words (0x%04x bytes)", "PC", pc.value, pc.value_in_bytes)
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
      ext_io_registers.reset
      sram.reset
      reset
      sp.value = device.ram_end
    end

    sig { void }
    def reset
      @pc.value = device.reset_address
      @next_pc.value = @pc.value
      sreg.reset
      reset_clkpr
    end

    sig { void }
    def reset_clkpr
      return unless ext_io_registers.registers.key?("CLKPR")

      clkpr = ext_io_registers.registers["CLKPR"]
      return unless clkpr.is_a?(MemoryByteRegisterWithNamedBits)

      ckdiv8 = device.fuses.programmed?(:CKDIV8)

      clkpr.CLKPS0 = ckdiv8
      clkpr.CLKPS1 = ckdiv8
      clkpr.CLKPS2 = false
      clkpr.CLKPS3 = false

      nil
    end

    sig { returns(Integer) }
    def fetch
      word = device.flash.word(next_pc.value)
      @next_pc.increment
      word
    end

    sig { params(mnemonic: Symbol, args: T.untyped).returns(Instruction) }
    def instruction(mnemonic, *args)
      Instruction.new(self, mnemonic, args)
    end

    sig { returns(Integer) }
    def interrupt_vector_table_start_address
      # We use 0-based addresses here rather than 2-based as in the AVR documentation because the interrupt
      # vector map includes RESET at 0. The actual reset vector may be overridden based on the BOOTRST fuse.
      self.MCUCR.IVSEL ? device.boot_area_start_address : 0
    end

    sig { params(name_or_vector_number: T.any(Symbol, Integer)).void }
    def interrupt(name_or_vector_number)
      sreg.I = false
      case name_or_vector_number
      when Integer
        vector_offset = name_or_vector_number * 2 # Each vector is 32 bits; offset is in words.
      when Symbol
        vector_offset = device.interrupt_vector_map[name_or_vector_number]
      end

      instruction(:call, Value.new(interrupt_vector_table_start_address + vector_offset)).execute
    end

    sig { returns(Instruction) }
    def decode
      offset = next_pc.value
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
      save_pc = pc.value
      save_next_pc = next_pc.value
      i = decode
      @pc.value = save_pc
      @next_pc.value = save_next_pc
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
