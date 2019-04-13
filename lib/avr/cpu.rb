require "avr/cpu/decoder"

module AVR
  class CPU
    attr_reader :device
    attr_accessor :pc
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
        io_registers.add(MemoryByteRegister.new(self, name.to_s, @sram.memory[address])) if address
      end

      @sreg = SREG.new(self, @sram.memory[device.data_memory_map[:SREG]])

      @sp = SP.new(self,
        @sram.memory[device.data_memory_map[:SPL]],
        @sram.memory[device.data_memory_map[:SPH]],
        device.ram_end)

      @decoder = Decoder.new(self, device.flash)

      @ports = {}
      device.port_map.each do |name, addr|
        @ports[name] = Port.new(self, name, addr[:pin], addr[:ddr], addr[:port])
      end

      @clock = Clock.new("cpu")
      @clock.push_sink(Clock::Sink.new("cpu") {
        self.step
      })

      @tracer = nil
    end

    def trace(&block)
      @tracer = nil
      @tracer = block.to_proc if block_given?
    end

    def print_status
      puts "Status:"
      puts "%8s = %d" % ["Ticks", clock.ticks]
      puts "%8s = %04x" % ["PC", pc]
      puts "%8s = %04x" % ["SP", sp.value]
      puts "%8s = [%s]" % ["SREG", sreg.bit_values]
      puts
      puts "Registers:"
      registers.print_status
      puts
      puts "IO Registers:"
      io_registers.print_status
      puts
      puts "IO Ports:"
      puts "%4s  %s" % ["", Port::PINS.join(" ")]
      ports.each do |name, port|
        puts "%4s: %s" % [name, port.pin_states.join(" ")]
      end
      puts
      puts "Next instruction:"
      puts "  " + peek.to_s
      puts
    end

    def reset
      @pc = 0
    end

    def fetch
      word = device.flash.word(pc)
      @pc += 1
      word
    end

    def decode
      decoder.decode
    end

    def peek
      save_pc = pc
      i = decode
      @pc = save_pc
      i
    end

    def step
      i = decode
      @tracer.call(i) if @tracer
      i.execute
    end

    def instruction(offset, mnemonic, *args)
      decoder.instruction(offset, mnemonic, *args)
    end
  end
end
