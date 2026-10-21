# typed: strict
# frozen_string_literal: true

module AVR
  class Device
    class Atmel_ATmega32u4 < Device # rubocop:disable Naming/ClassAndModuleCamelCase
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
        2560
      end

      sig { override.returns(Integer) }
      def flash_size
        32_768
      end

      sig { override.returns(Integer) }
      def eeprom_size
        1024
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
          EXTENDED: [:BODLEVEL0, :BODLEVEL1, :BODLEVEL2, :HWBE, nil, nil, nil, nil],
        }.freeze
      end

      sig { override.returns(T::Hash[Symbol, Integer]) }
      def fuse_default_values
        @fuse_default_values ||= {
          LOW:      0x5e,
          HIGH:     0x99,
          EXTENDED: 0xf3,
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
      def register_memory_map # rubocop:disable Metrics/MethodLength
        @register_memory_map ||= {
          # 32 registers, r0-r31
          PINB:    0x0023,
          DDRB:    0x0024,
          PORTB:   0x0025,
          PINC:    0x0026,
          DDRC:    0x0027,
          PORTC:   0x0028,
          PIND:    0x0029,
          DDRD:    0x002a,
          PORTD:   0x002b,
          PINE:    0x002c,
          DDRE:    0x002d,
          PORTE:   0x002e,
          PINF:    0x002f,
          DDRF:    0x0030,
          PORTF:   0x0031,
          TIFR0:   0x0035,
          TIFR1:   0x0036,
          TIFR3:   0x0038,
          TIFR4:   0x0039,
          PCIFR:   0x003b,
          EIFR:    0x003c,
          EIMSK:   0x003d,
          GPIOR0:  0x003e,
          EECR:    0x003f,
          EEDR:    0x0040,
          EEARL:   0x0041,
          EEARH:   0x0042,
          GTCCR:   0x0043,
          TCCR0A:  0x0044,
          TCCR0B:  0x0045,
          TCNT0:   0x0046,
          OCR0A:   0x0047,
          OCR0B:   0x0048,
          PLLCSR:  0x0049,
          GPIOR1:  0x004a,
          GPIOR2:  0x004b,
          SPCR:    0x004c,
          SPSR:    0x004d,
          SPDR:    0x004e,
          ACSR:    0x0050,
          OCDR:    0x0051,
          PLLFRQ:  0x0052,
          SMCR:    0x0053,
          MCUSR:   0x0054,
          MCUCR:   0x0055,
          SPMCSR:  0x0057,
          RAMPZ:   0x005b,
          EIND:    0x005c,
          SPL:     0x005d,
          SPH:     0x005e,
          SREG:    0x005f,
          WDTCSR:  0x0060,
          CLKPR:   0x0061,
          PRR0:    0x0064,
          PRR1:    0x0065,
          OSCCAL:  0x0066,
          RCCTRL:  0x0067,
          PCICR:   0x0068,
          EICRA:   0x0069,
          EICRB:   0x006a,
          PCMSK0:  0x006b,
          TIMSK0:  0x006e,
          TIMSK1:  0x006f,
          TIMSK3:  0x0071,
          TIMSK4:  0x0072,
          ADCL:    0x0078,
          ADCH:    0x0079,
          ADCSRA:  0x007a,
          ADCSRB:  0x007b,
          ADMUX:   0x007c,
          DIDR2:   0x007d,
          DIDR0:   0x007e,
          DIDR1:   0x007f,
          TCCR1A:  0x0080,
          TCCR1B:  0x0081,
          TCCR1C:  0x0082,
          TCNT1L:  0x0084,
          TCNT1H:  0x0085,
          ICR1L:   0x0086,
          ICR1H:   0x0087,
          OCR1AL:  0x0088,
          OCR1AH:  0x0089,
          OCR1BL:  0x008a,
          OCR1BH:  0x008b,
          OCR1CL:  0x008c,
          OCR1CH:  0x008d,
          TCCR3A:  0x0090,
          TCCR3B:  0x0091,
          TCCR3C:  0x0092,
          TCNT3L:  0x0094,
          TCNT3H:  0x0095,
          ICR3L:   0x0096,
          ICR3H:   0x0097,
          OCR3AL:  0x0098,
          OCR3AH:  0x0099,
          OCR3BL:  0x009a,
          OCR3BH:  0x009b,
          OCR3CL:  0x009c,
          OCR3CH:  0x009d,
          TWBR:    0x00b8,
          TWSR:    0x00b9,
          TWAR:    0x00ba,
          TWDR:    0x00bb,
          TWCR:    0x00bc,
          TWAMR:   0x00bd,
          TCNT4:   0x00be,
          TC4H:    0x00bf,
          TCCR4A:  0x00c0,
          TCCR4B:  0x00c1,
          TCCR4C:  0x00c2,
          TCCR4D:  0x00c3,
          TCCR4E:  0x00c4,
          CLKSEL0: 0x00c5,
          CLKSEL1: 0x00c6,
          CLKSTA:  0x00c7,
          UCSR1A:  0x00c8,
          UCSR1B:  0x00c9,
          UCSR1C:  0x00ca,
          UCSR1D:  0x00cb,
          UBRR1L:  0x00cc,
          UBRR1H:  0x00cd,
          UDR1:    0x00ce,
          OCR4A:   0x00cf,
          OCR4B:   0x00d0,
          OCR4C:   0x00d1,
          OCR4D:   0x00d2,
          DT4:     0x00d4,
          UHWCON:  0x00d7,
          USBCON:  0x00d8,
          USBSTA:  0x00d9,
          USBINT:  0x00da,
          UDCON:   0x00e0,
          UDINT:   0x00e1,
          UDIEN:   0x00e2,
          UDADDR:  0x00e3,
          UDFNUML: 0x00e4,
          UDFNUMH: 0x00e5,
          UDMFN:   0x00e6,
          UEINTX:  0x00e8,
          UENUM:   0x00e9,
          UERST:   0x00ea,
          UECONX:  0x00eb,
          UECFG0X: 0x00ec,
          UECFG1X: 0x00ed,
          UESTA0X: 0x00ee,
          UESTA1X: 0x00ef,
          UEIENX:  0x00f0,
          UEDATX:  0x00f1,
          UEBCLX:  0x00f2,
          UEBCHX:  0x00f3,
          UEINT:   0x00f4,
        }.freeze
      end

      sig { override.returns(T::Hash[Symbol, T::Array[T.nilable(Symbol)]]) }
      def register_bit_names_map
        @register_bit_names_map ||= {
          PINB:    [:PINB0, :PINB1, :PINB2, :PINB3, :PINB4, :PINB5, :PINB6, :PINB7],
          DDRB:    [:DDB0, :DDB1, :DDB2, :DDB3, :DDB4, :DDB5, :DDB6, :DDB7],
          PORTB:   [:PORTB0, :PORTB1, :PORTB2, :PORTB3, :PORTB4, :PORTB5, :PORTB6, :PORTB7],
          PINC:    [nil, nil, nil, nil, nil, nil, :PINC6, :PINC7],
          DDRC:    [nil, nil, nil, nil, nil, nil, :DDC6, :DDC7],
          PORTC:   [nil, nil, nil, nil, nil, nil, :PORTC6, :PORTC7],
          PIND:    [:PIND0, :PIND1, :PIND2, :PIND3, :PIND4, :PIND5, :PIND6, :PIND7],
          DDRD:    [:DDD0, :DDD1, :DDD2, :DDD3, :DDD4, :DDD5, :DDD6, :DDD7],
          PORTD:   [:PORTD0, :PORTD1, :PORTD2, :PORTD3, :PORTD4, :PORTD5, :PORTD6, :PORTD7],
          PINE:    [nil, nil, :PINE2, nil, nil, nil, :PINE6, nil],
          DDRE:    [nil, nil, :DDE2, nil, nil, nil, :DDE6, nil],
          PORTE:   [nil, nil, :PORTE2, nil, nil, nil, :PORTE6, nil],
          PINF:    [:PINF0, :PINF1, nil, nil, :PINF4, :PINF5, :PINF6, :PINF7],
          DDRF:    [:DDF0, :DDF1, nil, nil, :DDF4, :DDF5, :DDF6, :DDF7],
          PORTF:   [:PORTF0, :PORTF1, nil, nil, :PORTF4, :PORTF5, :PORTF6, :PORTF7],
          TIFR0:   [:TOV0, :OCF0A, :OCF0B, nil, nil, nil, nil, nil],
          TIFR1:   [:TOV1, :OCF1A, :OCF1B, :OCF1C, nil, :ICF1, nil, nil],
          TIFR3:   [:TOV3, :OCF3A, :OCF3B, :OCF3C, nil, :ICF3, nil, nil],
          TIFR4:   [nil, nil, :TOV4, nil, nil, :OCF4B, :OCF4A, :OCF4D],
          PCIFR:   [:PCIF0, nil, nil, nil, nil, nil, nil, nil],
          EIFR:    [:INTF0, :INTF1, :INTF2, :INTF3, nil, nil, :INTF6, nil],
          EIMSK:   [:INT0, :INT1, :INT2, :INT3, nil, nil, :INT6, nil],
          EECR:    [:EERE, :EEPE, :EEMPE, :EERIE, :EEPM0, :EEPM1, nil, nil],
          GTCCR:   [:PSRSYNC, :PSRASY, nil, nil, nil, nil, nil, :TSM],
          TCCR0A:  [:WGM00, :WGM01, nil, nil, :COM0B0, :COM0B1, :COM0A0, :COM0A1],
          TCCR0B:  [:CS00, :CS01, :CS02, :WGM02, nil, nil, :FOC0B, :FOC0A],
          PLLCSR:  [:PLOCK, :PLLE, nil, nil, :PINDIV, nil, nil, nil],
          SPCR:    [:SPR0, :SPR1, :CPHA, :CPOL, :MSTR, :DORD, :SPE, :SPIE],
          SPSR:    [:SPI2X, nil, nil, nil, nil, nil, :WCOL, :SPIF],
          ACSR:    [:ACIS0, :ACIS1, :ACIC, :ACIE, :ACI, :ACO, :ACBG, :ACD],
          PLLFRQ:  [:PDIV0, :PDIV1, :PDIV2, :PDIV3, :PLLTM0, :PLLTM1, :PLLUSB, :PINMUX],
          SMCR:    [:SE, :SM0, :SM1, :SM2, nil, nil, nil, nil],
          MCUSR:   [:PORF, :EXTRF, :BORF, :WDRF, :JTRF, :USBRF, nil, nil],
          MCUCR:   [:IVCE, :IVSEL, nil, nil, :PUD, nil, nil, :JTD],
          SPMCSR:  [:SPMEN, :PGERS, :PGWRT, :BLBSET, :RWWSRE, :SIGRD, :RWWSB, :SPMIE],
          SREG:    [:C, :Z, :N, :V, :S, :H, :T, :I],
          WDTCSR:  [:WDP0, :WDP1, :WDP2, :WDE, :WDCE, :WDP3, :WDIE, :WDIF],
          CLKPR:   [:CLKPS0, :CLKPS1, :CLKPS2, :CLKPS3, nil, nil, nil, :CLKPCE],
          PRR0:    [:PRADC, nil, :PRSPI, :PRTIM1, nil, :PRTIM0, nil, :PRTWI],
          PRR1:    [:PRUSART1, nil, nil, :PRTIM3, :PRTIM4, nil, nil, :PRUSB],
          RCCTRL:  [:RCFINE, nil, nil, nil, nil, nil, nil, nil],
          PCICR:   [:PCIE0, nil, nil, nil, nil, nil, nil, nil],
          EICRA:   [:ISC00, :ISC01, :ISC10, :ISC11, :ISC20, :ISC21, :ISC30, :ISC31],
          EICRB:   [nil, nil, nil, nil, :ISC60, :ISC61, nil, nil],
          PCMSK0:  [:PCINT0, :PCINT1, :PCINT2, :PCINT3, :PCINT4, :PCINT5, :PCINT6, :PCINT7],
          TIMSK0:  [:TOIE0, :OCIE0A, :OCIE0B, nil, nil, nil, nil, nil],
          TIMSK1:  [:TOIE1, :OCIE1A, :OCIE1B, :OCIE1C, nil, :ICIE1, nil, nil],
          TIMSK3:  [:TOIE3, :OCIE3A, :OCIE3B, :OCIE3C, nil, :ICIE3, nil, nil],
          TIMSK4:  [nil, nil, :TOIE4, nil, nil, :OCIE4B, :OCIE4A, :OCIE4D],
          ADCSRA:  [:ADPS0, :ADPS1, :ADPS2, :ADIE, :ADIF, :ADATE, :ADSC, :ADEN],
          ADCSRB:  [:ADTS0, :ADTS1, :ADTS2, :ADTS3, nil, :MUX5, :ACME, :ADHSM],
          ADMUX:   [:MUX0, :MUX1, :MUX2, :MUX3, :MUX4, :ADLAR, :REFS0, :REFS1],
          DIDR2:   [:ADC8D, :ADC9D, :ADC10D, :ADC11D, :ADC12D, :ADC13D, nil, nil],
          DIDR0:   [:ADC0D, :ADC1D, nil, nil, :ADC4D, :ADC5D, :ADC6D, :ADC7D],
          DIDR1:   [nil, :AIN0D, nil, nil, nil, nil, nil, nil],
          TCCR1A:  [:WGM10, :WGM11, :COM1C0, :COM1C1, :COM1B0, :COM1B1, :COM1A0, :COM1A1],
          TCCR1B:  [:CS10, :CS11, :CS12, :WGM12, :WGM13, nil, :ICES1, :ICNC1],
          TCCR1C:  [nil, nil, nil, nil, nil, :FOC1C, :FOC1B, :FOC1A],
          TCCR3A:  [:WGM30, :WGM31, :COM3C0, :COM3C1, :COM3B0, :COM3B1, :COM3A0, :COM3A1],
          TCCR3B:  [:CS30, :CS31, :CS32, :WGM32, :WGM33, nil, :ICES3, :ICNC3],
          TCCR3C:  [nil, nil, nil, nil, nil, :FOC3C, :FOC3B, :FOC3A],
          TWSR:    [:TWPS0, :TWPS1, nil, :TWS3, :TWS4, :TWS5, :TWS6, :TWS7],
          TWAR:    [:TWGCE, :TWA0, :TWA1, :TWA2, :TWA3, :TWA4, :TWA5, :TWA6],
          TWCR:    [:TWIE, nil, :TWEN, :TWWC, :TWSTO, :TWSTA, :TWEA, :TWINT],
          TWAMR:   [nil, :TWAM0, :TWAM1, :TWAM2, :TWAM3, :TWAM4, :TWAM5, :TWAM6],
          TCCR4A:  [:PWM4B, :PWM4A, :FOC4B, :FOC4A, :COM4B0, :COM4B1, :COM4A0, :COM4A1],
          TCCR4B:  [:CS40, :CS41, :CS42, :CS43, :DTPS40, :DTPS41, :PSR4, :PWM4X],
          TCCR4C:  [:PWM4D, :FOC4D, :COM4D0, :COM4D1, :COM4B0S, :COM4B1S, :COM4A0S, :COM4A1S],
          TCCR4D:  [:WGM40, :WGM41, :FPF4, :FPAC4, :FPES4, :FPNC4, :FPEN4, :FPIE4],
          TCCR4E:  [:OC4OE0, :OC4OE1, :OC4OE2, :OC4OE3, :OC4OE4, :OC4OE5, :ENHC4, :TLOCK4],
          CLKSEL0: [:CLKS, nil, :EXTE, :RCE, :EXSUT0, :EXSUT1, :RCSUT0, :RCSUT1],
          CLKSEL1: [:EXCKSEL0, :EXCKSEL1, :EXCKSEL2, :EXCKSEL3, :RCCKSEL0, :RCCKSEL1, :RCCKSEL2, :RCCKSEL3],
          CLKSTA:  [:EXTON, :RCON, nil, nil, nil, nil, nil, nil],
          UCSR1A:  [:MPCM1, :U2X1, :UPE1, :DOR1, :FE1, :UDRE1, :TXC1, :RXC1],
          UCSR1B:  [:TXB81, :RXB81, :UCSZ12, :TXEN1, :RXEN1, :UDRIE1, :TXCIE1, :RXCIE1],
          UCSR1C:  [:UCPOL1, :UCSZ10, :UCSZ11, :USBS1, :UPM10, :UPM11, :UMSEL10, :UMSEL11],
          UCSR1D:  [nil, :RTSEN, :CTSEN, nil, nil, nil, nil, nil],
          UHWCON:  [:UVREGE, nil, nil, nil, nil, nil, nil, nil],
          USBCON:  [:VBUSTE, nil, nil, nil, :OTGPADE, :FRZCLK, :USBE, nil],
          USBSTA:  [:VBUS, nil, nil, :SPEED, nil, nil, nil, nil],
          USBINT:  [:VBUSTI, nil, nil, nil, nil, nil, nil, nil],
          UDCON:   [:DETACH, :RMWKUP, :LSM, :RSTCPU, nil, nil, nil, nil],
          UDINT:   [:SUSPI, nil, :SOFI, :EORSTI, :WAKEUPI, :EORSMI, :UPRSMI, nil],
          UDIEN:   [:SUSPE, nil, :SOFE, :EORSTE, :WAKEUPE, :EORSME, :UPRSME, nil],
          UDADDR:  [:UADD0, :UADD1, :UADD2, :UADD3, :UADD4, :UADD5, :UADD6, :ADDEN],
          UDMFN:   [nil, nil, nil, nil, :FNCERR, nil, nil, nil],
          UEINTX:  [:TXINI, :STALLEDI, :RXOUTI, :RXSTPI, :NAKOUTI, :RWAL, :NAKINI, :FIFOCON],
          UENUM:   [:EPNUM0, :EPNUM1, :EPNUM2, nil, nil, nil, nil, nil],
          UERST:   [:EPRST0, :EPRST1, :EPRST2, :EPRST3, :EPRST4, :EPRST5, :EPRST6, nil],
          UECONX:  [:EPEN, nil, nil, :RSTDT, :STALLRQC, :STALLRQ, nil, nil],
          UECFG0X: [:EPDIR, nil, nil, nil, nil, nil, :EPTYPE0, :EPTYPE1],
          UECFG1X: [nil, :ALLOC, :EPBK0, :EPBK1, :EPSIZE0, :EPSIZE1, :EPSIZE2, nil],
          UESTA0X: [:NBUSYBK0, :NBUSYBK1, :DTSEQ0, :DTSEQ1, nil, :UNDERFI, :OVERFI, :CFGOK],
          UESTA1X: [:CURRBK0, :CURRBK1, :CTRLDIR, nil, nil, nil, nil, nil],
          UEIENX:  [:TXINE, :STALLEDE, :RXOUTE, :RXSTPE, :NAKOUTE, nil, :NAKINE, :FLERRE],
          UEINT:   [:EPINT0, :EPINT1, :EPINT2, :EPINT3, :EPINT4, :EPINT5, :EPINT6, nil],
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
            :INT3,
            :_RESERVED5,
            :_RESERVED6,
            :INT6,
            :_RESERVED8,
            :PCINT0,
            :USB_GEN,
            :USB_COM,
            :WDT,
            :_RESERVED13,
            :_RESERVED14,
            :_RESERVED15,
            :TIMER1_CAPT,
            :TIMER1_COMPA,
            :TIMER1_COMPB,
            :TIMER1_COMPC,
            :TIMER1_OVF,
            :TIMER0_COMPA,
            :TIMER0_COMPB,
            :TIMER0_OVF,
            :SPI_STC,
            :USART1_RX,
            :USART1_UDRE,
            :USART1_TX,
            :ANALOG_COMP,
            :ADC,
            :EE_READY,
            :TIMER3_CAPT,
            :TIMER3_COMPA,
            :TIMER3_COMPB,
            :TIMER3_COMPC,
            :TIMER3_OVF,
            :TWI,
            :SPM_READY,
            :TIMER4_COMPA,
            :TIMER4_COMPB,
            :TIMER4_COMPD,
            :TIMER4_OVF,
            :TIMER4_FPF,
          ]
        )
      end

      sig { override.returns(T::Hash[Symbol, T::Hash[Symbol, Integer]]) }
      def port_map
        @port_map ||= standard_ports([:B, :C, :D, :E, :F])
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
