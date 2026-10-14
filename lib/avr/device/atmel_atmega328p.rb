# typed: strict
# frozen_string_literal: true

module AVR
  class Device
    class Atmel_ATmega328p < Device # rubocop:disable Naming/ClassAndModuleCamelCase
      extend T::Sig

      sig { void }
      def initialize
        super

        # Type annotations for variables used in memoization.
        @register_bit_names_map = T.let(nil, T.nilable(T::Hash[Symbol, T::Array[T.nilable(Symbol)]]))
        @fuse_bit_names_map = T.let(nil, T.nilable(T::Hash[Symbol, T::Array[T.nilable(Symbol)]]))
        @word_register_map = T.let(nil, T.nilable(T::Hash[Symbol, T::Hash[Symbol, Integer]]))
        @data_memory_map = T.let(nil, T.nilable(T::Hash[Symbol, Integer]))
        @fuse_memory_map = T.let(nil, T.nilable(T::Hash[Symbol, Integer]))
        @fuse_default_values = T.let(nil, T.nilable(T::Hash[Symbol, Integer]))
        @boot_size_map = T.let(nil, T.nilable(T::Hash[Integer, Integer]))
        @interrupt_vector_map = T.let(nil, T.nilable(T::Hash[Symbol, Integer]))
        @port_map = T.let(nil, T.nilable(T::Hash[Symbol, T::Hash[Symbol, Integer]]))
      end

      sig { override.returns(Integer) }
      def sram_size
        2048
      end

      sig { override.returns(Integer) }
      def flash_size
        32_768
      end

      sig { override.returns(Integer) }
      def eeprom_size
        512
      end

      sig { override.returns(Integer) }
      def fuse_size
        3
      end

      sig { override.returns(T::Hash[Symbol, Integer]) }
      def fuse_memory_map
        @fuse_memory_map ||= {
          LOW:      0,
          HIGH:     1,
          EXTENDED: 2,
        }.freeze
      end

      sig { override.returns(T::Hash[Symbol, T::Array[T.nilable(Symbol)]]) }
      def fuse_bit_names_map
        @fuse_bit_names_map ||= {
          LOW:      [:CKSEL0, :CKSEL1, :CKSEL2, :CKSEL3, :SUT0, :SUT1, :CKOUT, :CKDIV8],
          HIGH:     [:BOOTRST, :BOOTSZ0, :BOOTSZ1, :EESAVE, :WDTON, :SPIEN, :DWEN, :RSTDISBL],
          EXTENDED: [:BODLEVEL0, :BODLEVEL1, :BODLEVEL2, nil, nil, nil, nil, nil],
        }.freeze
      end

      sig { override.returns(T::Hash[Symbol, Integer]) }
      def fuse_default_values
        @fuse_default_values ||= {
          LOW:      0x62,
          HIGH:     0xd9,
          EXTENDED: 0xff,
        }.freeze
      end

      sig { override.returns(T::Hash[Symbol, T::Hash[Symbol, Integer]]) }
      def word_register_map
        @word_register_map ||= {
          X: { l: 26, h: 27 },
          Y: { l: 28, h: 29 },
          Z: { l: 30, h: 31 },
        }
      end

      sig { override.returns(T::Hash[Symbol, Integer]) }
      def data_memory_map
        @data_memory_map ||= {
          # 32 registers, r0-r31
          PINB:   0x0023,
          DDRB:   0x0024,
          PORTB:  0x0025,
          PINC:   0x0026,
          DDRC:   0x0027,
          PORTC:  0x0028,
          PIND:   0x0029,
          DDRD:   0x002a,
          PORTD:  0x002b,
          TIFR0:  0x0035,
          TIFR1:  0x0036,
          TIFR2:  0x0037,
          PCIFR:  0x003b,
          EIFR:   0x003c,
          EIMSK:  0x003d,
          GPIOR0: 0x003e,
          EECR:   0x003f,
          EEDR:   0x0040,
          EEARL:  0x0041,
          EEARH:  0x0042,
          GTCCR:  0x0043,
          TCCR0A: 0x0044,
          TCCR0B: 0x0045,
          TCNT0:  0x0046,
          OCR0A:  0x0047,
          OCR0B:  0x0048,
          GPIOR1: 0x004a,
          GPIOR2: 0x004b,
          SPCR:   0x004c,
          SPSR:   0x004d,
          SPDR:   0x004e,
          ACSR:   0x0050,
          SMCR:   0x0053,
          MCUSR:  0x0054,
          MCUCR:  0x0055,
          SPMCSR: 0x0057,
          SPL:    0x005d,
          SPH:    0x005e,
          SREG:   0x005f,
          WDTCSR: 0x0060,
          CLKPR:  0x0061,
          PRR:    0x0064,
          OSCCAL: 0x0066,
          PCICR:  0x0068,
          EICRA:  0x0069,
          PCMSK0: 0x006b,
          PCMSK1: 0x006c,
          PCMSK2: 0x006d,
          TIMSK0: 0x006e,
          TIMSK1: 0x006f,
          TIMSK2: 0x0070,
          ADCL:   0x0078,
          ADCH:   0x0079,
          ADCSRA: 0x007a,
          ADCSRB: 0x007b,
          ADMUX:  0x007c,
          DIDR0:  0x007e,
          DIDR1:  0x007f,
          TCCR1A: 0x0080,
          TCCR1B: 0x0081,
          TCCR1C: 0x0082,
          TCNT1L: 0x0084,
          TCNT1H: 0x0085,
          ICR1L:  0x0086,
          ICR1H:  0x0087,
          OCR1AL: 0x0088,
          OCR1AH: 0x0089,
          OCR1BL: 0x008a,
          OCR1BH: 0x008b,
          TCCR2A: 0x00b0,
          TCCR2B: 0x00b1,
          TCNT2:  0x00b2,
          OCR2A:  0x00b3,
          OCR2B:  0x00b4,
          ASSR:   0x00b6,
          TWBR:   0x00b8,
          TWSR:   0x00b9,
          TWAR:   0x00ba,
          TWDR:   0x00bb,
          TWCR:   0x00bc,
          TWAMR:  0x00bd,
          UCSR0A: 0x00c0,
          UCSR0B: 0x00c1,
          UCSR0C: 0x00c2,
          UBRR0L: 0x00c4,
          UBRR0H: 0x00c5,
          UDR0:   0x00c6,
        }.freeze
      end

      sig { override.returns(T::Hash[Symbol, T::Array[T.nilable(Symbol)]]) }
      def register_bit_names_map
        @register_bit_names_map ||= {
          EECR: [:EERE, :EEPE, :EEMPE, :EERIE, :EEPM0, :EEPM1, nil, nil],
        }
      end

      sig { override.returns(Integer) }
      def register_start
        0x0000
      end

      sig { override.returns(Integer) }
      def register_count
        32
      end

      sig { override.returns(Integer) }
      def io_register_start
        0x0020
      end

      sig { override.returns(Integer) }
      def io_register_count
        64
      end

      sig { override.returns(Integer) }
      def ext_io_register_start
        0x0060
      end

      sig { override.returns(Integer) }
      def ext_io_register_count
        160
      end

      sig { override.returns(Integer) }
      def ram_start
        0x0100
      end

      sig { override.returns(Integer) }
      def ram_end
        ram_start + sram_size - 1
      end

      sig { override.returns(T::Hash[Symbol, Integer]) }
      def interrupt_vector_map
        @interrupt_vector_map ||= sequential_interrupt_vectors(
          [
            :RESET,
            :INT0,
            :INT1,
            :PCINT0,
            :PCINT1,
            :PCINT2,
            :WDT,
            :TIMER2_COMPA,
            :TIMER2_COMPB,
            :TIMER2_OVF,
            :TIMER1_CAPT,
            :TIMER1_COMPA,
            :TIMER1_COMPB,
            :TIMER1_OVF,
            :TIMER0_COMPA,
            :TIMER0_COMPB,
            :TIMER0_OVF,
            :SPI_STC,
            :USART_RX,
            :USART_UDRE,
            :USART_TX,
            :ADC,
            :EE_READY,
            :ANALOG_COMP,
            :TWI,
            :SPM_READY,
          ]
        )
      end

      sig { override.returns(T::Hash[Symbol, T::Hash[Symbol, Integer]]) }
      def port_map
        @port_map ||= standard_ports([:B, :C, :D])
      end

      sig { override.returns(T::Hash[Integer, Integer]) }
      def boot_size_map
        @boot_size_map ||= {
          3 => 256,
          2 => 512,
          1 => 1024,
          0 => 2048,
        }.freeze
      end
    end
  end
end
