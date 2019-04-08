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
    attr_reader :clock
    attr_reader :tracer

    def initialize(device)
      @device = device
      @pc = 0
      @sram = SRAM.new(device.ram_start + device.sram_size)
      @registers = RegisterFile.new(self)
      (0  .. 15).each { |n| registers.add(LowerRegister.new(self, "r#{n}", @sram.memory[n])) }
      (16 .. 31).each { |n| registers.add(UpperRegister.new(self, "r#{n}", @sram.memory[n])) }
      registers.add(RegisterPair.new(self, "X", r26, r27))
      registers.add(RegisterPair.new(self, "Y", r28, r29))
      registers.add(RegisterPair.new(self, "Z", r30, r31))
      @io_registers = RegisterFile.new(self)
      device.io_registers.each do |name|
        address = device.data_memory_map[name]
        io_registers.add(MemoryByteRegister.new(self, name.to_s, @sram.memory[address])) if address
      end
      
      @sp = SP.new(self,
        @sram.memory[device.data_memory_map[:SPL]],
        @sram.memory[device.data_memory_map[:SPH]],
        device.ram_end)
      @sreg = SREG.new(self, @sram.memory[device.data_memory_map[:SREG]])
      @decoder = Decoder.new(self, device.flash)

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
      puts "PC = %i" % [pc]
      puts "SP = %04x" % [sp.value]
      puts "Registers:"
      registers.print_status
      puts "IO Registers:"
      io_registers.print_status
      puts "Next: #{peek}"
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
      c = pc
      i = decode
      @pc = c
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
