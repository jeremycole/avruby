# frozen_string_literal: true

module AVR
  class CPU
    attr_reader :device
    attr_accessor :pc
    attr_accessor :next_pc
    attr_reader :sram
    attr_reader :registers
    attr_reader :io_registers
    attr_reader :sreg
    attr_reader :sp
    attr_reader :decoder
    attr_reader :ports
    attr_reader :clock
    attr_reader :tracer

    def initialize(device)
      @device = device
      @pc = 0
      @next_pc = 0
      @sram = SRAM.new(device.ram_start + device.sram_size)

      @registers = RegisterFile.new(self)

      device.register_count.times do |n|
        registers.add(MemoryByteRegister.new(self, "r#{n}", @sram.memory[n]))
      end

      device.word_register_map.each do |name, map|
        registers.add(RegisterPair.new(self, name, @registers[map[:l]], @registers[map[:h]]))
      end

      @io_registers = RegisterFile.new(self)
      device.io_registers.each do |name|
        address = device.data_memory_map[name]
        next unless address

        bit_names = device.register_bit_names_map[name]
        if bit_names
          io_registers.add(MemoryByteRegisterWithNamedBits.new(self, name.to_s, @sram.memory[address], bit_names))
        else
          io_registers.add(MemoryByteRegister.new(self, name.to_s, @sram.memory[address]))
        end
      end

      @sreg = SREG.new(self)

      @sp = SP.new(
        self,
        @sram.memory[device.data_memory_map[:SPL]],
        @sram.memory[device.data_memory_map[:SPH]],
        device.ram_end
      )

      @decoder = OpcodeDecoder.new

      @ports = {}
      device.port_map.each do |name, addr|
        @ports[name] = Port.new(self, name, addr[:pin], addr[:ddr], addr[:port])
      end

      @clock = Clock.new('cpu')
      @clock.push_sink(Clock::Sink.new('cpu') { step })

      @tracer = nil
    end

    def notify_at_tick(tick, &block)
      clock.notify_at_tick(tick, AVR::Clock::Sink.new("notify #{block} at #{tick}", block.to_proc))
    end

    def trace(&block)
      @tracer = nil
      @tracer = block.to_proc if block_given?
    end

    def print_status
      puts 'Status:'
      puts '%8s = %d' % ['Ticks', clock.ticks]
      puts '%8s = %d opcodes' % ['Cache', decoder.cache.size]
      puts '%8s = 0x%04x words' % ['PC', pc]
      puts '%8s = 0x%04x bytes' % ['PC', pc * 2]
      puts '%8s = 0x%04x (%d bytes used)' % ['SP', sp.value, device.ram_end - sp.value]
      puts '%8s = 0x%02x [%s]' % ['SREG', sreg.value, sreg.bit_values]
      puts
      puts 'Registers:'
      registers.print_status
      puts
      puts 'IO Registers:'
      io_registers.print_status
      puts
      puts 'IO Ports:'
      puts '%4s  %s' % ['', Port::PINS.join(' ')]
      ports.each do |name, port|
        puts '%4s: %s' % [name, port.pin_states.join(' ')]
      end
      puts
      puts 'Next instruction:'
      puts '  ' + peek.to_s
      puts
    end

    def reset_to_clean_state
      reset
      registers.reset
      io_registers.reset
      sram.reset
      sp.value = device.ram_end
    end

    def reset
      @pc = 0
      @next_pc = 0
      sreg.reset
    end

    def fetch
      word = device.flash.word(next_pc)
      @next_pc += 1
      word
    end

    def instruction(mnemonic, *args)
      AVR::Instruction.new(self, mnemonic, *args)
    end

    def interrupt(name_or_vector_number)
      sreg.I = false
      case name_or_vector_number
      when Integer
        address = name_or_vector_number * 2
      when Symbol
        address = device.interrupt_vector_map[name_or_vector_number]
      end

      instruction(:call, address).execute
    end

    def decode
      offset = next_pc
      word = fetch
      decoded_opcode = decoder.decode(word)
      unless decoded_opcode
        raise 'Unable to decode 0x%04x at offset 0x%04x words (0x%04x bytes)' % [
          word,
          offset,
          offset * 2,
        ]
      end

      decoded_opcode.opcode_definition.parse(
        self,
        decoded_opcode.opcode_definition,
        decoded_opcode.prepare_operands(self)
      )
    end

    def peek
      save_pc = pc
      save_next_pc = next_pc
      i = decode
      @pc = save_pc
      @next_pc = save_next_pc
      i
    end

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
