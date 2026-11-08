# typed: strict
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

    sig { returns(MemoryByteRegister) }
    def r0
      T.cast(T.must(registers.fetch(:r0)), MemoryByteRegister)
    end

    sig { params(value: Integer).void }
    def r0=(value)
      r0.value = value
    end

    sig { returns(MemoryByteRegister) }
    def r1
      T.cast(T.must(registers.fetch(:r1)), MemoryByteRegister)
    end

    sig { params(value: Integer).void }
    def r1=(value)
      r1.value = value
    end

    sig { returns(RegisterPair) }
    def r1r0
      @r1r0 ||= T.let(RegisterPair.new(self, r1, r0), T.nilable(AVR::RegisterPair))
    end

    sig { params(value: Integer).void }
    def r1r0=(value)
      r1r0.value = value
    end

    sig { returns(RegisterPair) }
    def X # rubocop:disable Naming/MethodName
      T.cast(T.must(registers.fetch(:X)), RegisterPair)
    end

    sig { returns(RegisterPair) }
    def Y # rubocop:disable Naming/MethodName
      T.cast(T.must(registers.fetch(:Y)), RegisterPair)
    end

    sig { returns(RegisterPair) }
    def Z # rubocop:disable Naming/MethodName
      T.cast(T.must(registers.fetch(:Z)), RegisterPair)
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
    def initialize(device) # rubocop:disable Metrics/AbcSize
      @device = device
      @pc = T.let(PC.new("pc", device.flash_size_in_words), PC)
      @next_pc = T.let(PC.new("next_pc", device.flash_size_in_words), PC)

      @data_address_space = T.let(Memory::AddressSpace.new("Data Address Space", 0xffff), AVR::Memory::AddressSpace)

      @register_memory = T.let(Memory::MemoryByteBacked.new("registers", device.register_count, 0), AVR::Memory::MemoryByteBacked)
      data_address_space.attach(@register_memory, 0)

      @registers = T.let(RegisterFile.new(self), AVR::RegisterFile)

      device.register_count.times do |n|
        registers.add(GeneralPurposeRegister.new(self, n, data_address_space[n]))
      end

      device.word_register_map.each do |name, map|
        registers.add(RegisterPair.new(self,
          T.cast(T.must(@registers[T.must(map[:h])]), MemoryByteRegister),
          T.cast(T.must(@registers[T.must(map[:l])]), MemoryByteRegister),
          name))
      end

      @io_register_memory = T.let(
        Memory::MemoryByteBacked.new("io_registers", device.io_register_count, 0),
        AVR::Memory::MemoryByteBacked
      )
      data_address_space.attach(@io_register_memory, device.io_register_start)

      @ext_io_register_memory = T.let(
        Memory::MemoryByteBacked.new("ext_io_registers", device.ext_io_register_count, 0),
        AVR::Memory::MemoryByteBacked
      )
      data_address_space.attach(@ext_io_register_memory, device.ext_io_register_start)

      @io_registers = T.let(RegisterFile.new(self), AVR::RegisterFile)
      @ext_io_registers = T.let(RegisterFile.new(self), AVR::RegisterFile)

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
              MemoryByteRegisterWithNamedBits.new(self, name, data_address_space[address], bit_names)
            )
          else
            register_file.add(MemoryByteRegister.new(self, name, data_address_space[address]))
          end
        end

        # Look for pairs of registers with the same prefix ending in H and L (such as TCNT1H and TCNT1L),
        # and make a word register for the pair. Some registers may end with "H" or "L" (such as OSCCAL),
        # but not be a pair, skip those.
        word_registers =
          register_file.registers.keys
                       .grep(/H$/)
                       .map { |k| k.to_s.sub(/H$/, "").to_sym }
                       .map { |k| [k, { h: register_file.registers[:"#{k}H"], l: register_file.registers[:"#{k}L"] }] }
                       .select { |_, v| v.values.all? }

        word_registers.each do |name, pair|
          register_file.add(RegisterPair.new(self, pair[:h], pair[:l], name))
        end
      end

      @sreg = T.let(SREG.new(self), AVR::SREG)

      @sp = T.let(SP.new(
        self,
        data_address_space[T.must(device.register_memory_map[:SPH])],
        data_address_space[T.must(device.register_memory_map[:SPL])],
        device.ram_end
      ), AVR::SP)

      @sram = T.let(Memory::SRAM.new(device.sram_size), AVR::Memory::SRAM)
      data_address_space.attach(@sram, device.ram_start)

      @decoder = T.let(OpcodeDecoder.new, AVR::OpcodeDecoder)

      @ports = T.let({}, T::Hash[T.untyped, T.untyped])
      device.port_map.each do |name, addr|
        @ports[name] = Port.new(self, name, T.must(addr[:pin]), T.must(addr[:ddr]), T.must(addr[:port]))
      end

      @clock = T.let(Clock.new("cpu"), AVR::Clock)
      @clock.push_sink(Clock::Sink.new("cpu") { step })

      @tracer = T.let(nil, T.nilable(T.proc.params(arg0: AVR::Instruction).void))
    end

    sig { params(tick: Integer, block: T.untyped).void }
    def notify_at_tick(tick, &block)
      clock.notify_at_tick(tick, Clock::Sink.new("notify #{block} at #{tick}", block.to_proc))
    end

    sig { params(block: T.nilable(T.proc.params(arg0: Instruction).void)).void }
    def trace(&block)
      @tracer = T.let(nil, T.nilable(T.proc.params(arg0: AVR::Instruction).void))
      @tracer = T.let(block.to_proc, T.nilable(T.proc.params(arg0: AVR::Instruction).void)) if block_given?
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
      return unless ext_io_registers.registers.key?(:CLKPR)

      clkpr = ext_io_registers.registers[:CLKPR]
      return unless clkpr.is_a?(MemoryByteRegisterWithNamedBits)

      ckdiv8 = device.fuses.programmed?(:CKDIV8)

      clkpr.set(:CLKPS0, ckdiv8 ? 1 : 0)
      clkpr.set(:CLKPS1, ckdiv8 ? 1 : 0)
      clkpr.set(:CLKPS2, 0)
      clkpr.set(:CLKPS3, 0)

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
      mcucr = T.cast(io_registers.registers.fetch(:MCUCR), MemoryByteRegisterWithNamedBits)
      mcucr.get(:IVSEL) == 1 ? device.boot_area_start_address : 0
    end

    sig { params(name_or_vector_number: T.any(Symbol, Integer)).void }
    def interrupt(name_or_vector_number)
      sreg.I = 0
      case name_or_vector_number
      when Integer
        vector_offset = name_or_vector_number * 2 # Each vector is 32 bits; offset is in words.
      when Symbol
        vector_offset = device.interrupt_vector_map[name_or_vector_number]
      end

      instruction(:call, Value.new(interrupt_vector_table_start_address + T.must(vector_offset))).execute
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
