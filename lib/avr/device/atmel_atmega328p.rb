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
        @word_register_map = T.let(nil, T.nilable(T::Hash[Symbol, T::Hash[Symbol, Integer]]))
        @data_memory_map = T.let(nil, T.nilable(T::Hash[Symbol, Integer]))
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
    end
  end
end
