# typed: strict
# frozen_string_literal: true

module AVR
  class Device
    class Atmel_ATtiny4 < Device # rubocop:disable Naming/ClassAndModuleCamelCase
      extend T::Sig

      sig { void }
      def initialize
        super

        # Type annotations for variables used in memoization.
        @register_bit_names_map = T.let(nil, T.nilable(T::Hash[Symbol, T::Array[T.nilable(Symbol)]]))
        @fuse_bit_names_map = T.let(nil, T.nilable(T::Hash[Symbol, T::Array[T.nilable(Symbol)]]))
        @word_register_map = T.let(nil, T.nilable(T::Hash[Symbol, T::Hash[Symbol, Integer]]))
        @register_memory_map = T.let(nil, T.nilable(T::Hash[Symbol, Integer]))
        @fuse_memory_map = T.let(nil, T.nilable(T::Hash[Symbol, Integer]))
        @fuse_default_values = T.let(nil, T.nilable(T::Hash[Symbol, Integer]))
        @boot_size_map = T.let(nil, T.nilable(T::Hash[Integer, Integer]))
        @interrupt_vector_map = T.let(nil, T.nilable(T::Hash[Symbol, Integer]))
        @port_map = T.let(nil, T.nilable(T::Hash[Symbol, T::Hash[Symbol, Integer]]))
      end

      sig { override.returns(Integer) }
      def sram_size
        32
      end

      sig { override.returns(Integer) }
      def flash_size
        512
      end

      sig { override.returns(Integer) }
      def eeprom_size
        0
      end

      sig { override.returns(Integer) }
      def fuse_size
        1
      end

      sig { override.returns(T::Hash[Symbol, Integer]) }
      def fuse_memory_map
        @fuse_memory_map ||= {
          CONFIGURATION: 0,
        }.freeze
      end

      sig { override.returns(T::Hash[Symbol, T::Array[T.nilable(Symbol)]]) }
      def fuse_bit_names_map
        @fuse_bit_names_map ||= {
          CONFIGURATION: [:RSTDISBL, :WDTON, :CKOUT, nil, nil, nil, nil, nil],
        }.freeze
      end

      sig { override.returns(T::Hash[Symbol, Integer]) }
      def fuse_default_values
        @fuse_default_values ||= {
          CONFIGURATION: 0xff,
        }.freeze
      end

      sig { override.returns(T::Hash[Symbol, Integer]) }
      def register_memory_map
        @register_memory_map ||= {
          # 32 registers, r0-r31
          PINB:   0x0020,
          DDRB:   0x0021,
          PORTB:  0x0022,
          PUEB:   0x0023,
          PORTCR: 0x002c,
          PCMSK:  0x0030,
          PCIFR:  0x0031,
          PCICR:   0x0032,
          EIMSK: 0x0033,
          EIFR:   0x0034,
          EICRA: 0x0035,
          DIDR0: 0x0037,
          ACSR: 0x003f,
          ICR0L: 0x0042,
          ICR0H: 0x0043,
          OCR0BL: 0x0044,
          OCR0BH: 0x0045,
          OCR0AL: 0x0046,
          OCR0AH: 0x0047,
          TCNT0L: 0x0048,
          TCNT0H: 0x0049,
          TIFR0: 0x004a,
          TIMSK0: 0x004b,
          TCCR0C: 0x004c,
          TCCR0B: 0x004d,
          TCCR0A: 0x004e,
          GTCCR: 0x004f,
          WDTCSR: 0x0051,
          NVMCSR: 0x0052,
          NVMCMD: 0x0053,
          VLMCSR: 0x0054,
          PRR: 0x0055,
          CLKPSR: 0x0056,
          CLKMSR: 0x0057,
          OSCCAL: 0x0059,
          SMCR: 0x005a,
          RSTFLR: 0x005b,
          CCP: 0x005c,
          SPL: 0x005d,
          SPH: 0x005e,
          SREG: 0x005f,
        }.freeze
      end

      sig { override.returns(T::Hash[Symbol, T::Array[T.nilable(Symbol)]]) }
      def register_bit_names_map
        @register_bit_names_map ||= {
          PINB:   [:PINB0, :PINB1, :PINB2, :PINB3, nil, nil, nil, nil],
          DDRB:   [:DDB0, :DDB1, :DDB2, :DDB3, nil, nil, nil, nil],
          PORTB:  [:PORTB0, :PORTB1, :PORTB2, :PORTB3, nil, nil, nil, nil],
          PUEB:   [:PUEB0, :PUEB1, :PUEB2, :PUEB3, nil, nil, nil, nil],
          PORTCR: [nil, :BBMB, nil, nil, nil, nil, nil, nil],
          PCMSK:  [:PCINT0, :PCINT1, :PCINT2, :PCINT3, nil, nil, nil, nil],
          PCIFR:  [:PCIF0, nil, nil, nil, nil, nil, nil, nil],
          PCICR:   [:PCIE0, nil, nil, nil, nil, nil, nil, nil],
          EIMSK: [:INT0, nil, nil, nil, nil, nil, nil, nil],
          EIFR:   [:INTF0, nil, nil, nil, nil, nil, nil, nil],
          EICRA: [:ISC00, :ISC01, nil, nil, nil, nil, nil, nil],
          DIDR0: [:ADC0D, :ADC1D, :ADC2D, :ADC3D, nil, nil, nil, nil],
          ACSR: [:ACIS0, :ACIS1, :ACIC, :ACIE, :ACI, :ACO, nil, :ACD],
          TIFR0: [:TOV0, :OCF0A, :OCF0B, nil, nil, :ICF0, nil, nil],
          TIMSK0: [:TOIE0, :OCIE0A, :OCIE0B, nil, nil, :OCIE0, nil, nil],
          TCCR0C: [nil, nil, nil, nil, nil, nil, :FOC0B, :FOC0A],
          TCCR0B: [:CS00, :CS01, :CS02, :WGM02, :WGM03, nil, :ICES0, :ICNC0],
          TCCR0A: [:WGM00, :WGM01, nil, nil, :COM0B0, :COM0B1, :COM0A0, :COM0A1],
          GTCCR: [:PSR, nil, nil, nil, nil, nil, nil, :TSM],
          WDTCSR: [:WDP0, :WDP1, :WDP2, :WDE, nil, :WDP3, :WDIE, :WDIF],
          NVMCSR: [nil, nil, nil, nil, nil, nil, nil, :NVMBSY],
          VLMCSR: [:VLM0, :VLM1, :VLM2, nil, nil, nil, :VLMIE, :VLMF],
          PRR: [:PRTIM0, :PRADC, nil, nil, nil, nil, nil, nil],
          CLKPSR: [:CLKPS0, :CLKPS1, :CLKPS2, :CLKPS3, nil, nil, nil, nil],
          CLKMSR: [:CLKMS0, :CLKMS1, nil, nil, nil, nil, nil, nil],
          SMCR: [:SE, :SM0, :SM1, :SM2, nil, nil, nil, nil],
          RSTFLR: [:PORF, :EXTRF, nil, :WDRF, nil, nil, nil, nil],
          SREG:  [:C, :Z, :N, :V, :S, :H, :T, :I],
        }.freeze
      end

      sig { override.returns(Integer) }
      def register_start
        0x0010
      end

      sig { override.returns(Integer) }
      def register_count
        16
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
        0
      end

      sig { override.returns(Integer) }
      def ext_io_register_count
        0
      end

      sig { override.returns(Integer) }
      def ram_start
        0x0060
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
            :PCINT0,
            :TIM0_CAPT,
            :TIM0_OVF,
            :TIM0_COMPA,
            :TIM0_COMPB,
            :ANA_COMP,
            :WDT,
            :VLM,
          ]
        )
      end

      sig { override.returns(T::Hash[Symbol, T::Hash[Symbol, Integer]]) }
      def port_map
        @port_map ||= standard_ports([:B])
      end

      sig { override.returns(T::Hash[Integer, Integer]) }
      def boot_size_map
        @boot_size_map ||= {}.freeze
      end
    end
  end
end
