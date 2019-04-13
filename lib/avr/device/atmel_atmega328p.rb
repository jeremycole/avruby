module AVR
  class Device::Atmel_ATmega328p < Device
    def sram_size
      2048
    end

    def flash_size
      32768
    end

    def eeprom_size
      512
    end

    def word_register_map
      @word_register_map ||= {
        "X" => { l: 26, h: 27 },
        "Y" => { l: 28, h: 29 },
        "Z" => { l: 30, h: 31 },
      }
    end

    def data_memory_map
      @data_memory_map ||= {
        # 32 registers, r0-r31
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
        EICRA:              0x0069,
      }.freeze
    end

    def register_start
      0x0000
    end

    def register_count
      32
    end

    def io_register_start
      0x0020
    end

    def io_register_count
      64
    end

    def ext_io_register_start
      0x0060
    end

    def ext_io_register_count
      160
    end

    def ram_start
      0x0100
    end

    def ram_end
      ram_start + sram_size - 1
    end

    def port_map
      @port_map ||= {
        B: {
          pin: data_memory_map[:PINB],
          ddr: data_memory_map[:DDRB],
          port: data_memory_map[:PORTB],
        },
        C: {
          pin: data_memory_map[:PINC],
          ddr: data_memory_map[:DDRC],
          port: data_memory_map[:PORTC],
        },
        D: {
          pin: data_memory_map[:PIND],
          ddr: data_memory_map[:DDRD],
          port: data_memory_map[:PORTD],
        },
      }
    end
  end
end