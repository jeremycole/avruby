require "avr/cpu/decoder"

module AVR
  class CPU
    DATA_MEMORY_MAP = {
      _REGISTERS:           0x0000,
        # 32 registers, r0-r31
      
      _IO_REGISTERS:        0x0020,
        PINB:               0x0023,
        DDRB:               0x0024,
        PORTB:              0x0025,
        PINC:               0x0026,
        DDRC:               0x0027,
        PORTC:              0x0028,
        PIND:               0x0029,
        DDRD:               0x002a,
        PORTD:              0x002b,
        TIFR0:              0x0035,
        TIFR1:              0x0035,
        TIFR2:              0x0035,
        PCIFR:              0x003b,
        EIFR:               0x003c,
        EIMSK:              0x003d,
        GPIOR0:             0x003e,
        EECR:               0x003f,
        EEDR:               0x0040,
        EEARL:              0x0041,
        EEARH:              0x0042,
        GTCCR:              0x0043,
        TCCR0A:             0x0044,
        TCCR0B:             0x0045,
        TCNT0:              0x0046,
        OCR0A:              0x0047,
        OCR0B:              0x0048,
        GPIOR1:             0x004a,
        GPIOR2:             0x004b,
        SPCR:               0x004c,
        SPSR:               0x004d,
        SPDR:               0x004e,
        ACSR:               0x0050,
        SMCR:               0x0053,
        MCUSR:              0x0054,
        MCUCR:              0x0055,
        SPMCSR:             0x0057,
        SPL:                0x005d,
        SPH:                0x005e,
        SREG:               0x005f,
      _EXT_IO_REGISTERS:    0x0060,
        EICRA:              0x0069,
      _RAM:                 0x0100,
      _RAMEND:              0x08ff,
    }.freeze

    DATA_MEMORY_MAP_BY_ADDRESS = AVR::CPU::DATA_MEMORY_MAP.each_with_object({}) { |(n, a), h|
      h[a] = n unless n =~ /^_/
    }

    IO_REGISTERS = (0..63).map { |i| DATA_MEMORY_MAP_BY_ADDRESS[i + DATA_MEMORY_MAP[:_IO_REGISTERS]] }

    attr_accessor :pc
    attr_reader :sram
    attr_reader :registers
    attr_reader :io_registers
    attr_reader :sreg
    attr_reader :sp
    attr_reader :flash
    attr_reader :eeprom
    attr_reader :decoder

    def initialize(sram_size, flash_size, eeprom_size)
      @pc = 0
      @sram = SRAM.new(self, DATA_MEMORY_MAP[:_RAM] + sram_size)
      @registers = RegisterFile.new(self)
      (0  .. 15).each { |n| registers.add(LowerRegister.new(self, "r#{n}", @sram.memory[n])) }
      (16 .. 31).each { |n| registers.add(UpperRegister.new(self, "r#{n}", @sram.memory[n])) }
      registers.add(RegisterPair.new(self, "X", r26, r27))
      registers.add(RegisterPair.new(self, "Y", r28, r29))
      registers.add(RegisterPair.new(self, "Z", r30, r31))
      @io_registers = RegisterFile.new(self)
      IO_REGISTERS.each do |name|
        address = DATA_MEMORY_MAP[name]
        io_registers.add(MemoryByteRegister.new(self, name.to_s, @sram.memory[address])) if address
      end
      
      @sp = SP.new(self,
        @sram.memory[DATA_MEMORY_MAP[:SPL]],
        @sram.memory[DATA_MEMORY_MAP[:SPH]],
        DATA_MEMORY_MAP[:_RAMEND])
      @sreg = SREG.new(self, @sram.memory[DATA_MEMORY_MAP[:SREG]])
      @flash = Flash.new(self, flash_size)
      @eeprom = EEPROM.new(self, eeprom_size)
      @decoder = Decoder.new(self, flash)
    end

    def reset
      @pc = 0
    end

    def fetch
      word = flash.word(pc)
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
      decode.execute
    end

    def instruction(offset, mnemonic, *args)
      decoder.instruction(offset, mnemonic, *args)
    end
  end
end
