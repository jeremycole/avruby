# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Device::Atmel_ATmega32u4) do
  let(:device) { described_class.new }
  let(:cpu) { device.cpu }
  let(:fuses) { device.fuses }

  it "has correct memory sizes" do
    expect(device.sram_size).to(eq(2560))
    expect(device.flash_size).to(eq(32_768))
    expect(device.eeprom_size).to(eq(1024))
    expect(device.fuse_size).to(eq(3))
  end

  it "has correct address space ranges" do
    expect(device.register_start).to(eq(0x0000))
    expect(device.register_count).to(eq(32))
    expect(device.io_register_start).to(eq(0x0020))
    expect(device.io_register_count).to(eq(64))
    expect(device.ext_io_register_start).to(eq(0x0060))
    expect(device.ext_io_register_count).to(eq(160))
    expect(device.ram_start).to(eq(0x0100))
    expect(device.ram_end).to(eq(0x0AFF))
  end

  it "has correct boot size map" do
    expect(device.boot_size_map).to(eq(
      {
        3 => 256,
        2 => 512,
        1 => 1024,
        0 => 2048,
      }
    ))
  end

  it "starts at PC 0 with default fuses (BOOTRST unprogrammed)" do
    expect(fuses.unprogrammed?(:BOOTRST)).to(be(true))
    expect(device.reset_address).to(eq(0))
    expect(cpu.pc).to(eq(0))
    expect(cpu.next_pc).to(eq(0))
  end

  it "has ports B, C, D, E, and F in port map" do
    expect(device.port_map.keys).to(contain_exactly(:B, :C, :D, :E, :F))
    expect(device.port_map[:B]).to(eq({ pin: 0x0023, ddr: 0x0024, port: 0x0025 }))
    expect(device.port_map[:C]).to(eq({ pin: 0x0026, ddr: 0x0027, port: 0x0028 }))
    expect(device.port_map[:D]).to(eq({ pin: 0x0029, ddr: 0x002a, port: 0x002b }))
    expect(device.port_map[:E]).to(eq({ pin: 0x002c, ddr: 0x002d, port: 0x002e }))
    expect(device.port_map[:F]).to(eq({ pin: 0x002f, ddr: 0x0030, port: 0x0031 }))
  end

  it "has all expected register memory map entries" do
    expect(device.register_memory_map[:PINB]).to(eq(0x0023))
    expect(device.register_memory_map[:DDRB]).to(eq(0x0024))
    expect(device.register_memory_map[:PORTB]).to(eq(0x0025))
    expect(device.register_memory_map[:PINC]).to(eq(0x0026))
    expect(device.register_memory_map[:DDRC]).to(eq(0x0027))
    expect(device.register_memory_map[:PORTC]).to(eq(0x0028))
    expect(device.register_memory_map[:PIND]).to(eq(0x0029))
    expect(device.register_memory_map[:DDRD]).to(eq(0x002a))
    expect(device.register_memory_map[:PORTD]).to(eq(0x002b))
    expect(device.register_memory_map[:PINE]).to(eq(0x002c))
    expect(device.register_memory_map[:DDRE]).to(eq(0x002d))
    expect(device.register_memory_map[:PORTE]).to(eq(0x002e))
    expect(device.register_memory_map[:PINF]).to(eq(0x002f))
    expect(device.register_memory_map[:DDRF]).to(eq(0x0030))
    expect(device.register_memory_map[:PORTF]).to(eq(0x0031))
    expect(device.register_memory_map[:TIFR0]).to(eq(0x0035))
    expect(device.register_memory_map[:TIFR1]).to(eq(0x0036))
    expect(device.register_memory_map[:TIFR3]).to(eq(0x0038))
    expect(device.register_memory_map[:TIFR4]).to(eq(0x0039))
    expect(device.register_memory_map[:PCIFR]).to(eq(0x003b))
    expect(device.register_memory_map[:EIFR]).to(eq(0x003c))
    expect(device.register_memory_map[:EIMSK]).to(eq(0x003d))
    expect(device.register_memory_map[:GPIOR0]).to(eq(0x003e))
    expect(device.register_memory_map[:EECR]).to(eq(0x003f))
    expect(device.register_memory_map[:EEDR]).to(eq(0x0040))
    expect(device.register_memory_map[:EEARL]).to(eq(0x0041))
    expect(device.register_memory_map[:EEARH]).to(eq(0x0042))
    expect(device.register_memory_map[:GTCCR]).to(eq(0x0043))
    expect(device.register_memory_map[:TCCR0A]).to(eq(0x0044))
    expect(device.register_memory_map[:TCCR0B]).to(eq(0x0045))
    expect(device.register_memory_map[:TCNT0]).to(eq(0x0046))
    expect(device.register_memory_map[:OCR0A]).to(eq(0x0047))
    expect(device.register_memory_map[:OCR0B]).to(eq(0x0048))
    expect(device.register_memory_map[:PLLCSR]).to(eq(0x0049))
    expect(device.register_memory_map[:GPIOR1]).to(eq(0x004a))
    expect(device.register_memory_map[:GPIOR2]).to(eq(0x004b))
    expect(device.register_memory_map[:SPCR]).to(eq(0x004c))
    expect(device.register_memory_map[:SPSR]).to(eq(0x004d))
    expect(device.register_memory_map[:SPDR]).to(eq(0x004e))
    expect(device.register_memory_map[:ACSR]).to(eq(0x0050))
    expect(device.register_memory_map[:OCDR]).to(eq(0x0051))
    expect(device.register_memory_map[:PLLFRQ]).to(eq(0x0052))
    expect(device.register_memory_map[:SMCR]).to(eq(0x0053))
    expect(device.register_memory_map[:MCUSR]).to(eq(0x0054))
    expect(device.register_memory_map[:MCUCR]).to(eq(0x0055))
    expect(device.register_memory_map[:SPMCSR]).to(eq(0x0057))
    expect(device.register_memory_map[:RAMPZ]).to(eq(0x005b))
    expect(device.register_memory_map[:EIND]).to(eq(0x005c))
    expect(device.register_memory_map[:SPL]).to(eq(0x005d))
    expect(device.register_memory_map[:SPH]).to(eq(0x005e))
    expect(device.register_memory_map[:SREG]).to(eq(0x005f))
    expect(device.register_memory_map[:WDTCSR]).to(eq(0x0060))
    expect(device.register_memory_map[:CLKPR]).to(eq(0x0061))
    expect(device.register_memory_map[:PRR0]).to(eq(0x0064))
    expect(device.register_memory_map[:PRR1]).to(eq(0x0065))
    expect(device.register_memory_map[:OSCCAL]).to(eq(0x0066))
    expect(device.register_memory_map[:RCCTRL]).to(eq(0x0067))
    expect(device.register_memory_map[:PCICR]).to(eq(0x0068))
    expect(device.register_memory_map[:EICRA]).to(eq(0x0069))
    expect(device.register_memory_map[:EICRB]).to(eq(0x006a))
    expect(device.register_memory_map[:PCMSK0]).to(eq(0x006b))
    expect(device.register_memory_map[:TIMSK0]).to(eq(0x006e))
    expect(device.register_memory_map[:TIMSK1]).to(eq(0x006f))
    expect(device.register_memory_map[:TIMSK3]).to(eq(0x0071))
    expect(device.register_memory_map[:TIMSK4]).to(eq(0x0072))
    expect(device.register_memory_map[:ADCL]).to(eq(0x0078))
    expect(device.register_memory_map[:ADCH]).to(eq(0x0079))
    expect(device.register_memory_map[:ADCSRA]).to(eq(0x007a))
    expect(device.register_memory_map[:ADCSRB]).to(eq(0x007b))
    expect(device.register_memory_map[:ADMUX]).to(eq(0x007c))
    expect(device.register_memory_map[:DIDR2]).to(eq(0x007d))
    expect(device.register_memory_map[:DIDR0]).to(eq(0x007e))
    expect(device.register_memory_map[:DIDR1]).to(eq(0x007f))
    expect(device.register_memory_map[:TCCR1A]).to(eq(0x0080))
    expect(device.register_memory_map[:TCCR1B]).to(eq(0x0081))
    expect(device.register_memory_map[:TCCR1C]).to(eq(0x0082))
    expect(device.register_memory_map[:TCNT1L]).to(eq(0x0084))
    expect(device.register_memory_map[:TCNT1H]).to(eq(0x0085))
    expect(device.register_memory_map[:ICR1L]).to(eq(0x0086))
    expect(device.register_memory_map[:ICR1H]).to(eq(0x0087))
    expect(device.register_memory_map[:OCR1AL]).to(eq(0x0088))
    expect(device.register_memory_map[:OCR1AH]).to(eq(0x0089))
    expect(device.register_memory_map[:OCR1BL]).to(eq(0x008a))
    expect(device.register_memory_map[:OCR1BH]).to(eq(0x008b))
    expect(device.register_memory_map[:OCR1CL]).to(eq(0x008c))
    expect(device.register_memory_map[:OCR1CH]).to(eq(0x008d))
    expect(device.register_memory_map[:TCCR3A]).to(eq(0x0090))
    expect(device.register_memory_map[:TCCR3B]).to(eq(0x0091))
    expect(device.register_memory_map[:TCCR3C]).to(eq(0x0092))
    expect(device.register_memory_map[:TCNT3L]).to(eq(0x0094))
    expect(device.register_memory_map[:TCNT3H]).to(eq(0x0095))
    expect(device.register_memory_map[:ICR3L]).to(eq(0x0096))
    expect(device.register_memory_map[:ICR3H]).to(eq(0x0097))
    expect(device.register_memory_map[:OCR3AL]).to(eq(0x0098))
    expect(device.register_memory_map[:OCR3AH]).to(eq(0x0099))
    expect(device.register_memory_map[:OCR3BL]).to(eq(0x009a))
    expect(device.register_memory_map[:OCR3BH]).to(eq(0x009b))
    expect(device.register_memory_map[:OCR3CL]).to(eq(0x009c))
    expect(device.register_memory_map[:OCR3CH]).to(eq(0x009d))
    expect(device.register_memory_map[:TWBR]).to(eq(0x00b8))
    expect(device.register_memory_map[:TWSR]).to(eq(0x00b9))
    expect(device.register_memory_map[:TWAR]).to(eq(0x00ba))
    expect(device.register_memory_map[:TWDR]).to(eq(0x00bb))
    expect(device.register_memory_map[:TWCR]).to(eq(0x00bc))
    expect(device.register_memory_map[:TWAMR]).to(eq(0x00bd))
    expect(device.register_memory_map[:TCNT4]).to(eq(0x00be))
    expect(device.register_memory_map[:TC4H]).to(eq(0x00bf))
    expect(device.register_memory_map[:TCCR4A]).to(eq(0x00c0))
    expect(device.register_memory_map[:TCCR4B]).to(eq(0x00c1))
    expect(device.register_memory_map[:TCCR4C]).to(eq(0x00c2))
    expect(device.register_memory_map[:TCCR4D]).to(eq(0x00c3))
    expect(device.register_memory_map[:TCCR4E]).to(eq(0x00c4))
    expect(device.register_memory_map[:CLKSEL0]).to(eq(0x00c5))
    expect(device.register_memory_map[:CLKSEL1]).to(eq(0x00c6))
    expect(device.register_memory_map[:CLKSTA]).to(eq(0x00c7))
    expect(device.register_memory_map[:UCSR1A]).to(eq(0x00c8))
    expect(device.register_memory_map[:UCSR1B]).to(eq(0x00c9))
    expect(device.register_memory_map[:UCSR1C]).to(eq(0x00ca))
    expect(device.register_memory_map[:UCSR1D]).to(eq(0x00cb))
    expect(device.register_memory_map[:UBRR1L]).to(eq(0x00cc))
    expect(device.register_memory_map[:UBRR1H]).to(eq(0x00cd))
    expect(device.register_memory_map[:UDR1]).to(eq(0x00ce))
    expect(device.register_memory_map[:OCR4A]).to(eq(0x00cf))
    expect(device.register_memory_map[:OCR4B]).to(eq(0x00d0))
    expect(device.register_memory_map[:OCR4C]).to(eq(0x00d1))
    expect(device.register_memory_map[:OCR4D]).to(eq(0x00d2))
    expect(device.register_memory_map[:DT4]).to(eq(0x00d4))
    expect(device.register_memory_map[:UHWCON]).to(eq(0x00d7))
    expect(device.register_memory_map[:USBCON]).to(eq(0x00d8))
    expect(device.register_memory_map[:USBSTA]).to(eq(0x00d9))
    expect(device.register_memory_map[:USBINT]).to(eq(0x00da))
    expect(device.register_memory_map[:UDCON]).to(eq(0x00e0))
    expect(device.register_memory_map[:UDINT]).to(eq(0x00e1))
    expect(device.register_memory_map[:UDIEN]).to(eq(0x00e2))
    expect(device.register_memory_map[:UDADDR]).to(eq(0x00e3))
    expect(device.register_memory_map[:UDFNUML]).to(eq(0x00e4))
    expect(device.register_memory_map[:UDFNUMH]).to(eq(0x00e5))
    expect(device.register_memory_map[:UDMFN]).to(eq(0x00e6))
    expect(device.register_memory_map[:UEINTX]).to(eq(0x00e8))
    expect(device.register_memory_map[:UENUM]).to(eq(0x00e9))
    expect(device.register_memory_map[:UERST]).to(eq(0x00ea))
    expect(device.register_memory_map[:UECONX]).to(eq(0x00eb))
    expect(device.register_memory_map[:UECFG0X]).to(eq(0x00ec))
    expect(device.register_memory_map[:UECFG1X]).to(eq(0x00ed))
    expect(device.register_memory_map[:UESTA0X]).to(eq(0x00ee))
    expect(device.register_memory_map[:UESTA1X]).to(eq(0x00ef))
    expect(device.register_memory_map[:UEIENX]).to(eq(0x00f0))
    expect(device.register_memory_map[:UEDATX]).to(eq(0x00f1))
    expect(device.register_memory_map[:UEBCLX]).to(eq(0x00f2))
    expect(device.register_memory_map[:UEBCHX]).to(eq(0x00f3))
    expect(device.register_memory_map[:UEINT]).to(eq(0x00f4))
  end

  it "has all expected register bit names map entries" do
    expect(device.register_bit_names_map[:TIMSK0]).to(eq([:TOIE0, :OCIE0A, :OCIE0B, nil, nil, nil, nil, nil]))
    expect(device.register_bit_names_map[:TIMSK1]).to(eq([:TOIE1, :OCIE1A, :OCIE1B, :OCIE1C, nil, :ICIE1, nil, nil]))
    expect(device.register_bit_names_map[:TIMSK3]).to(eq([:TOIE3, :OCIE3A, :OCIE3B, :OCIE3C, nil, :ICIE3, nil, nil]))
    expect(device.register_bit_names_map[:TIMSK4]).to(eq([nil, nil, :TOIE4, nil, nil, :OCIE4B, :OCIE4A, :OCIE4D]))
    expect(device.register_bit_names_map[:TIFR0]).to(eq([:TOV0, :OCF0A, :OCF0B, nil, nil, nil, nil, nil]))
    expect(device.register_bit_names_map[:TIFR1]).to(eq([:TOV1, :OCF1A, :OCF1B, :OCF1C, nil, :ICF1, nil, nil]))
    expect(device.register_bit_names_map[:TIFR3]).to(eq([:TOV3, :OCF3A, :OCF3B, :OCF3C, nil, :ICF3, nil, nil]))
    expect(device.register_bit_names_map[:TIFR4]).to(eq([nil, nil, :TOV4, nil, nil, :OCF4B, :OCF4A, :OCF4D]))
    expect(device.register_bit_names_map[:PCIFR]).to(eq([:PCIF0, nil, nil, nil, nil, nil, nil, nil]))
    expect(device.register_bit_names_map[:EIFR]).to(eq([:INTF0, :INTF1, :INTF2, :INTF3, nil, nil, :INTF6, nil]))
    expect(device.register_bit_names_map[:EIMSK]).to(eq([:INT0, :INT1, :INT2, :INT3, nil, nil, :INT6, nil]))
    expect(device.register_bit_names_map[:EICRA]).to(eq(
      [:ISC00, :ISC01, :ISC10, :ISC11, :ISC20, :ISC21, :ISC30, :ISC31]
    ))
    expect(device.register_bit_names_map[:EICRB]).to(eq([nil, nil, nil, nil, :ISC60, :ISC61, nil, nil]))
    expect(device.register_bit_names_map[:PRR0]).to(eq(
      [:PRADC, nil, :PRSPI, :PRTIM1, nil, :PRTIM0, nil, :PRTWI]
    ))
    expect(device.register_bit_names_map[:PRR1]).to(eq(
      [:PRUSART1, nil, nil, :PRTIM3, :PRTIM4, nil, nil, :PRUSB]
    ))
    expect(device.register_bit_names_map[:USBCON]).to(eq(
      [:VBUSTE, nil, nil, nil, :OTGPADE, :FRZCLK, :USBE, nil]
    ))
    expect(device.register_bit_names_map[:UDCON]).to(eq(
      [:DETACH, :RMWKUP, :LSM, :RSTCPU, nil, nil, nil, nil]
    ))
    expect(device.register_bit_names_map[:UEINTX]).to(eq(
      [:TXINI, :STALLEDI, :RXOUTI, :RXSTPI, :NAKOUTI, :RWAL, :NAKINI, :FIFOCON]
    ))
    expect(device.register_bit_names_map[:TCCR4A]).to(eq(
      [:PWM4B, :PWM4A, :FOC4B, :FOC4A, :COM4B0, :COM4B1, :COM4A0, :COM4A1]
    ))
    expect(device.register_bit_names_map[:TCCR4B]).to(eq(
      [:CS40, :CS41, :CS42, :CS43, :DTPS40, :DTPS41, :PSR4, :PWM4X]
    ))
    expect(device.register_bit_names_map[:TCCR4C]).to(eq(
      [:PWM4D, :FOC4D, :COM4D0, :COM4D1, :COM4B0S, :COM4B1S, :COM4A0S, :COM4A1S]
    ))
    expect(device.register_bit_names_map[:TCCR4D]).to(eq(
      [:WGM40, :WGM41, :FPF4, :FPAC4, :FPES4, :FPNC4, :FPEN4, :FPIE4]
    ))
    expect(device.register_bit_names_map[:TCCR4E]).to(eq(
      [:OC4OE0, :OC4OE1, :OC4OE2, :OC4OE3, :OC4OE4, :OC4OE5, :ENHC4, :TLOCK4]
    ))
  end

  it "has correct interrupt vectors" do
    expect(device.interrupt_vector_map[:RESET]).to(eq(0x0000))
    expect(device.interrupt_vector_map[:INT0]).to(eq(0x0002))
    expect(device.interrupt_vector_map[:INT1]).to(eq(0x0004))
    expect(device.interrupt_vector_map[:INT2]).to(eq(0x0006))
    expect(device.interrupt_vector_map[:INT3]).to(eq(0x0008))
    expect(device.interrupt_vector_map[:INT6]).to(eq(0x000e))
    expect(device.interrupt_vector_map[:PCINT0]).to(eq(0x0012))
    expect(device.interrupt_vector_map[:USB_GEN]).to(eq(0x0014))
    expect(device.interrupt_vector_map[:USB_COM]).to(eq(0x0016))
    expect(device.interrupt_vector_map[:WDT]).to(eq(0x0018))
    expect(device.interrupt_vector_map[:TIMER1_CAPT]).to(eq(0x0020))
    expect(device.interrupt_vector_map[:TIMER1_COMPA]).to(eq(0x0022))
    expect(device.interrupt_vector_map[:TIMER1_COMPB]).to(eq(0x0024))
    expect(device.interrupt_vector_map[:TIMER1_COMPC]).to(eq(0x0026))
    expect(device.interrupt_vector_map[:TIMER1_OVF]).to(eq(0x0028))
    expect(device.interrupt_vector_map[:TIMER0_COMPA]).to(eq(0x002a))
    expect(device.interrupt_vector_map[:TIMER0_COMPB]).to(eq(0x002c))
    expect(device.interrupt_vector_map[:TIMER0_OVF]).to(eq(0x002e))
    expect(device.interrupt_vector_map[:SPI_STC]).to(eq(0x0030))
    expect(device.interrupt_vector_map[:USART1_RX]).to(eq(0x0032))
    expect(device.interrupt_vector_map[:USART1_UDRE]).to(eq(0x0034))
    expect(device.interrupt_vector_map[:USART1_TX]).to(eq(0x0036))
    expect(device.interrupt_vector_map[:ANALOG_COMP]).to(eq(0x0038))
    expect(device.interrupt_vector_map[:ADC]).to(eq(0x003a))
    expect(device.interrupt_vector_map[:EE_READY]).to(eq(0x003c))
    expect(device.interrupt_vector_map[:TIMER3_CAPT]).to(eq(0x003e))
    expect(device.interrupt_vector_map[:TIMER3_COMPA]).to(eq(0x0040))
    expect(device.interrupt_vector_map[:TIMER3_COMPB]).to(eq(0x0042))
    expect(device.interrupt_vector_map[:TIMER3_COMPC]).to(eq(0x0044))
    expect(device.interrupt_vector_map[:TIMER3_OVF]).to(eq(0x0046))
    expect(device.interrupt_vector_map[:TWI]).to(eq(0x0048))
    expect(device.interrupt_vector_map[:SPM_READY]).to(eq(0x004a))
    expect(device.interrupt_vector_map[:TIMER4_COMPA]).to(eq(0x004c))
    expect(device.interrupt_vector_map[:TIMER4_COMPB]).to(eq(0x004e))
    expect(device.interrupt_vector_map[:TIMER4_COMPD]).to(eq(0x0050))
    expect(device.interrupt_vector_map[:TIMER4_OVF]).to(eq(0x0052))
    expect(device.interrupt_vector_map[:TIMER4_FPF]).to(eq(0x0054))
  end

  it "calculates correct boot reset address for each BOOTSZ setting" do
    # Flash size = 32768 bytes = 16384 words (0x4000)
    # BOOTSZ = 0 -> 2048 words -> 0x3800 (14336)
    expect(fuses.composites[:BOOTSZ]).to(eq(0))
    expect(device.boot_area_start_address).to(eq(0x3800))

    # BOOTSZ = 1 -> 1024 words -> 0x3C00 (15360)
    fuses.set([0x5e, 0x99 | 0b011, 0xf3])
    cpu.reset
    expect(fuses.composites[:BOOTSZ]).to(eq(1))
    expect(device.boot_area_start_address).to(eq(0x3C00))

    # BOOTSZ = 2 -> 512 words -> 0x3E00 (15872)
    fuses.set([0x5e, 0x99 | 0b101, 0xf3])
    cpu.reset
    expect(fuses.composites[:BOOTSZ]).to(eq(2))
    expect(device.boot_area_start_address).to(eq(0x3E00))

    # BOOTSZ = 3 -> 256 words -> 0x3F00 (16128)
    fuses.set([0x5e, 0x99 | 0b111, 0xf3])
    cpu.reset
    expect(fuses.composites[:BOOTSZ]).to(eq(3))
    expect(device.boot_area_start_address).to(eq(0x3F00))
  end

  it "initializes CLKPR CLKPS bits based on CKDIV8 fuse" do
    # Default LOW fuse is 0x5e (CKDIV8 is programmed / 0) -> CLKPS = 0b0011 (3)
    expect(fuses.programmed?(:CKDIV8)).to(be(true))
    expect(cpu.CLKPR.CLKPS0).to(be(true))
    expect(cpu.CLKPR.CLKPS1).to(be(true))
    expect(cpu.CLKPR.CLKPS2).to(be(false))
    expect(cpu.CLKPR.CLKPS3).to(be(false))
    expect(cpu.CLKPR.value).to(eq(0x03))

    # When CKDIV8 is unprogrammed (1), e.g. LOW = 0xde -> CLKPS = 0b0000 (0)
    fuses.set([0xde, 0x99, 0xf3])
    cpu.reset

    expect(fuses.programmed?(:CKDIV8)).to(be(false))
    expect(cpu.CLKPR.CLKPS0).to(be(false))
    expect(cpu.CLKPR.CLKPS1).to(be(false))
    expect(cpu.CLKPR.CLKPS2).to(be(false))
    expect(cpu.CLKPR.CLKPS3).to(be(false))
    expect(cpu.CLKPR.value).to(eq(0x00))

    # When reset_to_clean_state is called with CKDIV8 programmed -> CLKPS = 0b0011 (3)
    fuses.reset_to_defaults
    cpu.reset_to_clean_state
    expect(cpu.CLKPR.value).to(eq(0x03))
  end
end
