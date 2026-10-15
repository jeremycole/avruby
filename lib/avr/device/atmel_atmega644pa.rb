# typed: strict
# frozen_string_literal: true

module AVR
  class Device
    class Atmel_ATmega644pa < Device # rubocop:disable Naming/ClassAndModuleCamelCase
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
        4096
      end

      sig { override.returns(Integer) }
      def flash_size
        65_536
      end

      sig { override.returns(Integer) }
      def eeprom_size
        2048
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
          HIGH:     [:BOOTRST, :BOOTSZ0, :BOOTSZ1, :EESAVE, :WDTON, :SPIEN, :JTAGEN, :OCDEN],
          EXTENDED: [:BODLEVEL0, :BODLEVEL1, :BODLEVEL2, nil, nil, nil, nil, nil],
        }.freeze
      end

      sig { override.returns(T::Hash[Symbol, Integer]) }
      def fuse_default_values
        @fuse_default_values ||= {
          LOW:      0x62,
          HIGH:     0x99,
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
      def register_memory_map
        @register_memory_map ||= {
          # 32 registers, r0-r31
          PINA:   0x0020,
          DDRA:   0x0021,
          PORTA:  0x0022,
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
          OCDR:   0x0051,
          SMCR:   0x0053,
          MCUSR:  0x0054,
          MCUCR:  0x0055,
          SPMCSR: 0x0057,
          SPL:    0x005d,
          SPH:    0x005e,
          SREG:   0x005f,
          WDTCSR: 0x0060,
          CLKPR:  0x0061,
          PRR0:   0x0064,
          OSCCAL: 0x0066,
          PCICR:  0x0068,
          EICRA:  0x0069,
          PCMSK0: 0x006b,
          PCMSK1: 0x006c,
          PCMSK2: 0x006d,
          TIMSK0: 0x006e,
          TIMSK1: 0x006f,
          TIMSK2: 0x0070,
          PCMSK3: 0x0073,
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
          UCSR1A: 0x00c8,
          UCSR1B: 0x00c9,
          UCSR1C: 0x00ca,
          UBRR1L: 0x00cc,
          UBRR1H: 0x00cd,
          UDR1:   0x00ce,
        }.freeze
      end

      sig { override.returns(T::Hash[Symbol, T::Array[T.nilable(Symbol)]]) }
      def register_bit_names_map
        @register_bit_names_map ||= {
          PINA:   [:PINA0, :PINA1, :PINA2, :PINA3, :PINA4, :PINA5, :PINA6, :PINA7],
          DDRA:   [:DDA0, :DDA1, :DDA2, :DDA3, :DDA4, :DDA5, :DDA6, :DDA7],
          PORTA:  [:PORTA0, :PORTA1, :PORTA2, :PORTA3, :PORTA4, :PORTA5, :PORTA6, :PORTA7],
          PINB:   [:PINB0, :PINB1, :PINB2, :PINB3, :PINB4, :PINB5, :PINB6, :PINB7],
          DDRB:   [:DDB0, :DDB1, :DDB2, :DDB3, :DDB4, :DDB5, :DDB6, :DDB7],
          PORTB:  [:PORTB0, :PORTB1, :PORTB2, :PORTB3, :PORTB4, :PORTB5, :PORTB6, :PORTB7],
          PINC:   [:PINC0, :PINC1, :PINC2, :PINC3, :PINC4, :PINC5, :PINC6, :PINC7],
          DDRC:   [:DDC0, :DDC1, :DDC2, :DDC3, :DDC4, :DDC5, :DDC6, :DDC7],
          PORTC:  [:PORTC0, :PORTC1, :PORTC2, :PORTC3, :PORTC4, :PORTC5, :PORTC6, :PORTC7],
          PIND:   [:PIND0, :PIND1, :PIND2, :PIND3, :PIND4, :PIND5, :PIND6, :PIND7],
          DDRD:   [:DDD0, :DDD1, :DDD2, :DDD3, :DDD4, :DDD5, :DDD6, :DDD7],
          PORTD:  [:PORTD0, :PORTD1, :PORTD2, :PORTD3, :PORTD4, :PORTD5, :PORTD6, :PORTD7],
          TIFR0:  [:TOV0, :OCF0A, :OCF0B, nil, nil, nil, nil, nil],
          TIFR1:  [:TOV1, :OCF1A, :OCF1B, nil, nil, :ICF1, nil, nil],
          TIFR2:  [:TOV2, :OCF2A, :OCF2B, nil, nil, nil, nil, nil],
          PCIFR:  [:PCIF0, :PCIF1, :PCIF2, :PCIF3, nil, nil, nil, nil],
          EIFR:   [:INTF0, :INTF1, :INTF2, nil, nil, nil, nil, nil],
          EIMSK:  [:INT0, :INT1, :INT2, nil, nil, nil, nil, nil],
          EECR:   [:EERE, :EEPE, :EEMPE, :EERIE, :EEPM0, :EEPM1, nil, nil],
          GTCCR:  [:PSR10, :PSR2, nil, nil, nil, nil, nil, :TSM],
          TCCR0A: [:WGM00, :WGM01, nil, nil, :COM0B0, :COM0B1, :COM0A0, :COM0A1],
          TCCR0B: [:CS00, :CS01, :CS02, :WGM02, nil, nil, :FOC0B, :FOC0A],
          SPCR:   [:SPR0, :SPR1, :CPHA, :CPOL, :MSTR, :DORD, :SPE, :SPIE],
          SPSR:   [:SPI2X, nil, nil, nil, nil, nil, :WCOL, :SPIF],
          ACSR:   [:ACIS0, :ACIS1, :ACIC, :ACIE, :ACI, :ACO, :ACBG, :ACD],
          SMCR:   [:SE, :SM0, :SM1, :SM2, nil, nil, nil, nil],
          MCUSR:  [:PORF, :EXTRF, :BORF, :WDRF, :JTRF, nil, nil, nil],
          MCUCR:  [:IVCE, :IVSEL, nil, nil, :PUD, :BODSE, :BODS, :JTD],
          SPMCSR: [:SPMEN, :PGERS, :PGWRT, :BLBSET, :RWWSRE, :SIGRD, :RWWSB, :SPMIE],
          SREG:   [:C, :Z, :N, :V, :S, :H, :T, :I],
          WDTCSR: [:WDP0, :WDP1, :WDP2, :WDE, :WDCE, :WDP3, :WDIE, :WDIF],
          CLKPR:  [:CLKPS0, :CLKPS1, :CLKPS2, :CLKPS3, nil, nil, nil, :CLKPCE],
          PRR0:   [:PRADC, :PRUSART0, :PRSPI, :PRTIM1, :PRUSART1, :PRTIM0, :PRTIM2, :PRTWI],
          PCICR:  [:PCIE0, :PCIE1, :PCIE2, :PCIE3, nil, nil, nil, nil],
          EICRA:  [:ISC00, :ISC01, :ISC10, :ISC11, :ISC20, :ISC21, nil, nil],
          PCMSK0: [:PCINT0, :PCINT1, :PCINT2, :PCINT3, :PCINT4, :PCINT5, :PCINT6, :PCINT7],
          PCMSK1: [:PCINT8, :PCINT9, :PCINT10, :PCINT11, :PCINT12, :PCINT13, :PCINT14, :PCINT15],
          PCMSK2: [:PCINT16, :PCINT17, :PCINT18, :PCINT19, :PCINT20, :PCINT21, :PCINT22, :PCINT23],
          PCMSK3: [:PCINT24, :PCINT25, :PCINT26, :PCINT27, :PCINT28, :PCINT29, :PCINT30, :PCINT31],
          TIMSK0: [:TOIE0, :OCIE0A, :OCIE0B, nil, nil, nil, nil, nil],
          TIMSK1: [:TOIE1, :OCIE1A, :OCIE1B, nil, nil, :ICIE1, nil, nil],
          TIMSK2: [:TOIE2, :OCIE2A, :OCIE2B, nil, nil, nil, nil, nil],
          ADCSRA: [:ADPS0, :ADPS1, :ADPS2, :ADIE, :ADIF, :ADATE, :ADSC, :ADEN],
          ADCSRB: [:ADTS0, :ADTS1, :ADTS2, nil, nil, nil, :ACME, nil],
          ADMUX:  [:MUX0, :MUX1, :MUX2, :MUX3, :MUX4, :ADLAR, :REFS0, :REFS1],
          DIDR0:  [:ADC0D, :ADC1D, :ADC2D, :ADC3D, :ADC4D, :ADC5D, :ADC6D, :ADC7D],
          DIDR1:  [:AIN0D, :AIN1D, nil, nil, nil, nil, nil, nil],
          TCCR1A: [:WGM10, :WGM11, nil, nil, :COM1B0, :COM1B1, :COM1A0, :COM1A1],
          TCCR1B: [:CS10, :CS11, :CS12, :WGM12, :WGM13, nil, :ICES1, :ICNC1],
          TCCR1C: [nil, nil, nil, nil, nil, nil, :FOC1B, :FOC1A],
          TCCR2A: [:WGM20, :WGM21, nil, nil, :COM2B0, :COM2B1, :COM2A0, :COM2A1],
          TCCR2B: [:CS20, :CS21, :CS22, :WGM22, nil, nil, :FOC2B, :FOC2A],
          ASSR:   [:TCR2BUB, :TCR2AUB, :OCR2BUB, :OCR2AUB, :TCN2UB, :AS2, :EXCLK, nil],
          TWSR:   [:TWPS0, :TWPS1, nil, :TWS3, :TWS4, :TWS5, :TWS6, :TWS7],
          TWAR:   [:TWGCE, :TWA0, :TWA1, :TWA2, :TWA3, :TWA4, :TWA5, :TWA6],
          TWCR:   [:TWIE, nil, :TWEN, :TWWC, :TWSTO, :TWSTA, :TWEA, :TWINT],
          TWAMR:  [nil, :TWAM0, :TWAM1, :TWAM2, :TWAM3, :TWAM4, :TWAM5, :TWAM6],
          UCSR0A: [:MPCM0, :U2X0, :UPE0, :DOR0, :FE0, :UDRE0, :TXC0, :RXC0],
          UCSR0B: [:TXB80, :RXB80, :UCSZ02, :TXEN0, :RXEN0, :UDRIE0, :TXCIE0, :RXCIE0],
          UCSR0C: [:UCPOL0, :UCSZ00, :UCSZ01, :USBS0, :UPM00, :UPM01, :UMSEL00, :UMSEL01],
          UCSR1A: [:MPCM1, :U2X1, :UPE1, :DOR1, :FE1, :UDRE1, :TXC1, :RXC1],
          UCSR1B: [:TXB81, :RXB81, :UCSZ12, :TXEN1, :RXEN1, :UDRIE1, :TXCIE1, :RXCIE1],
          UCSR1C: [:UCPOL1, :UCSZ10, :UCSZ11, :USBS1, :UPM10, :UPM11, :UMSEL10, :UMSEL11],
        }.freeze
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
            :INT2,
            :PCINT0,
            :PCINT1,
            :PCINT2,
            :PCINT3,
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
            :USART0_RX,
            :USART0_UDRE,
            :USART0_TX,
            :ANALOG_COMP,
            :ADC,
            :EE_READY,
            :TWI,
            :SPM_READY,
            :USART1_RX,
            :USART1_UDRE,
            :USART1_TX,
          ]
        )
      end

      sig { override.returns(T::Hash[Symbol, T::Hash[Symbol, Integer]]) }
      def port_map
        @port_map ||= standard_ports([:A, :B, :C, :D])
      end

      sig { override.returns(T::Hash[Integer, Integer]) }
      def boot_size_map
        @boot_size_map ||= {
          3 => 512,
          2 => 1024,
          1 => 2048,
          0 => 4096,
        }.freeze
      end
    end
  end
end
