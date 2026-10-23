# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Device::Atmel_ATmega328p) do
  let(:device) { described_class.new }
  let(:cpu) { device.cpu }
  let(:fuses) { device.fuses }

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
    expect(fuses.bootrst?).to(be(false))
    expect(device.reset_address).to(eq(0))
    expect(cpu.pc).to(eq(0))
    expect(cpu.next_pc).to(eq(0))
  end

  it "has all expected register memory map entries" do
    expect(device.register_memory_map[:TIFR0]).to(eq(0x0035))
    expect(device.register_memory_map[:TIFR1]).to(eq(0x0036))
    expect(device.register_memory_map[:TIFR2]).to(eq(0x0037))
    expect(device.register_memory_map[:WDTCSR]).to(eq(0x0060))
    expect(device.register_memory_map[:CLKPR]).to(eq(0x0061))
    expect(device.register_memory_map[:PRR]).to(eq(0x0064))
    expect(device.register_memory_map[:OSCCAL]).to(eq(0x0066))
    expect(device.register_memory_map[:PCICR]).to(eq(0x0068))
    expect(device.register_memory_map[:EICRA]).to(eq(0x0069))
    expect(device.register_memory_map[:PCMSK0]).to(eq(0x006b))
    expect(device.register_memory_map[:PCMSK1]).to(eq(0x006c))
    expect(device.register_memory_map[:PCMSK2]).to(eq(0x006d))
    expect(device.register_memory_map[:TIMSK0]).to(eq(0x006e))
    expect(device.register_memory_map[:TIMSK1]).to(eq(0x006f))
    expect(device.register_memory_map[:TIMSK2]).to(eq(0x0070))
    expect(device.register_memory_map[:ADCL]).to(eq(0x0078))
    expect(device.register_memory_map[:ADCH]).to(eq(0x0079))
    expect(device.register_memory_map[:ADCSRA]).to(eq(0x007a))
    expect(device.register_memory_map[:ADCSRB]).to(eq(0x007b))
    expect(device.register_memory_map[:ADMUX]).to(eq(0x007c))
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
    expect(device.register_memory_map[:TCCR2A]).to(eq(0x00b0))
    expect(device.register_memory_map[:TCCR2B]).to(eq(0x00b1))
    expect(device.register_memory_map[:TCNT2]).to(eq(0x00b2))
    expect(device.register_memory_map[:OCR2A]).to(eq(0x00b3))
    expect(device.register_memory_map[:OCR2B]).to(eq(0x00b4))
    expect(device.register_memory_map[:ASSR]).to(eq(0x00b6))
    expect(device.register_memory_map[:TWBR]).to(eq(0x00b8))
    expect(device.register_memory_map[:TWSR]).to(eq(0x00b9))
    expect(device.register_memory_map[:TWAR]).to(eq(0x00ba))
    expect(device.register_memory_map[:TWDR]).to(eq(0x00bb))
    expect(device.register_memory_map[:TWCR]).to(eq(0x00bc))
    expect(device.register_memory_map[:TWAMR]).to(eq(0x00bd))
    expect(device.register_memory_map[:UCSR0A]).to(eq(0x00c0))
    expect(device.register_memory_map[:UCSR0B]).to(eq(0x00c1))
    expect(device.register_memory_map[:UCSR0C]).to(eq(0x00c2))
    expect(device.register_memory_map[:UBRR0L]).to(eq(0x00c4))
    expect(device.register_memory_map[:UBRR0H]).to(eq(0x00c5))
    expect(device.register_memory_map[:UDR0]).to(eq(0x00c6))
  end

  it "has all expected register bit names map entries" do
    expect(device.register_bit_names_map[:TIMSK0]).to(eq([:TOIE0, :OCIE0A, :OCIE0B, nil, nil, nil, nil, nil]))
    expect(device.register_bit_names_map[:TIMSK1]).to(eq([:TOIE1, :OCIE1A, :OCIE1B, nil, nil, :ICIE1, nil, nil]))
    expect(device.register_bit_names_map[:TIMSK2]).to(eq([:TOIE2, :OCIE2A, :OCIE2B, nil, nil, nil, nil, nil]))
    expect(device.register_bit_names_map[:TIFR0]).to(eq([:TOV0, :OCF0A, :OCF0B, nil, nil, nil, nil, nil]))
    expect(device.register_bit_names_map[:TIFR1]).to(eq([:TOV1, :OCF1A, :OCF1B, nil, nil, :ICF1, nil, nil]))
    expect(device.register_bit_names_map[:TIFR2]).to(eq([:TOV2, :OCF2A, :OCF2B, nil, nil, nil, nil, nil]))
    expect(device.register_bit_names_map[:GTCCR]).to(eq([:PSRSYNC, :PSRASY, nil, nil, nil, nil, nil, :TSM]))
    expect(device.register_bit_names_map[:PRR]).to(eq(
      [:PRADC, :PRUSART0, :PRSPI, :PRTIM1, nil, :PRTIM0, :PRTIM2, :PRTWI]
    ))
    expect(device.register_bit_names_map[:ADMUX]).to(eq([:MUX0, :MUX1, :MUX2, :MUX3, nil, :ADLAR, :REFS0, :REFS1]))
    expect(device.register_bit_names_map[:DIDR0]).to(eq([:ADC0D, :ADC1D, :ADC2D, :ADC3D, :ADC4D, :ADC5D, nil, nil]))
    expect(device.register_bit_names_map[:PCIFR]).to(eq([:PCIF0, :PCIF1, :PCIF2, nil, nil, nil, nil, nil]))
    expect(device.register_bit_names_map[:EIFR]).to(eq([:INTF0, :INTF1, nil, nil, nil, nil, nil, nil]))
    expect(device.register_bit_names_map[:EIMSK]).to(eq([:INT0, :INT1, nil, nil, nil, nil, nil, nil]))
    expect(device.register_bit_names_map[:EICRA]).to(eq([:ISC00, :ISC01, :ISC10, :ISC11, nil, nil, nil, nil]))
    expect(device.register_bit_names_map[:MCUCR]).to(eq([:IVCE, :IVSEL, nil, nil, :PUD, :BODSE, :BODS, nil]))
    expect(device.register_bit_names_map[:MCUSR]).to(eq([:PORF, :EXTRF, :BORF, :WDRF, nil, nil, nil, nil]))
    expect(device.register_bit_names_map[:SPMCSR]).to(eq(
      [:SPMEN, :PGERS, :PGWRT, :BLBSET, :RWWSRE, :SIGRD, :RWWSB, :SPMIE]
    ))
    expect(device.register_bit_names_map[:UCSR0A]).to(eq(
      [:MPCM0, :U2X0, :UPE0, :DOR0, :FE0, :UDRE0, :TXC0, :RXC0]
    ))
    expect(device.register_bit_names_map[:UCSR0B]).to(eq(
      [:TXB80, :RXB80, :UCSZ02, :TXEN0, :RXEN0, :UDRIE0, :TXCIE0, :RXCIE0]
    ))
    expect(device.register_bit_names_map[:UCSR0C]).to(eq(
      [:UCPOL0, :UCSZ00, :UCSZ01, :USBS0, :UPM00, :UPM01, :UMSEL00, :UMSEL01]
    ))
  end

  it "calculates correct boot reset address for each BOOTSZ setting" do
    # Flash size = 32768 bytes = 16384 words (0x4000)
    # BOOTSZ = 3 -> 256 words -> 0x3F00 (16128)
    fuses.HIGH.BOOTSZ0 = true
    fuses.HIGH.BOOTSZ1 = true
    expect(fuses.BOOTSZ).to(eq(3))
    expect(device.boot_reset_address).to(eq(0x3F00))

    # BOOTSZ = 2 -> 512 words -> 0x3E00 (15872)
    fuses.HIGH.BOOTSZ0 = false
    fuses.HIGH.BOOTSZ1 = true
    expect(fuses.BOOTSZ).to(eq(2))
    expect(device.boot_reset_address).to(eq(0x3E00))

    # BOOTSZ = 1 -> 1024 words -> 0x3C00 (15360)
    fuses.HIGH.BOOTSZ0 = true
    fuses.HIGH.BOOTSZ1 = false
    expect(fuses.BOOTSZ).to(eq(1))
    expect(device.boot_reset_address).to(eq(0x3C00))

    # BOOTSZ = 0 -> 2048 words -> 0x3800 (14336)
    fuses.HIGH.BOOTSZ0 = false
    fuses.HIGH.BOOTSZ1 = false
    expect(fuses.BOOTSZ).to(eq(0))
    expect(device.boot_reset_address).to(eq(0x3800))
  end

  it "sets CPU pc and next_pc to boot reset address when BOOTRST is programmed" do
    # 0xde: BOOTRST = 0 (programmed), BOOTSZ1..0 = 11b (3) -> 0x3F00
    fuses.set([0xff, 0xde, 0x05])
    expect(fuses.bootrst?).to(be(true))
    expect(fuses.BOOTSZ).to(eq(3))
    expect(device.reset_address).to(eq(0x3F00))
    expect(cpu.pc).to(eq(0x3F00))
    expect(cpu.next_pc).to(eq(0x3F00))

    # 0xd8: BOOTRST = 0 (programmed), BOOTSZ1..0 = 00b (0) -> 0x3800
    fuses.set([0x62, 0xd8, 0xff])
    expect(fuses.bootrst?).to(be(true))
    expect(fuses.BOOTSZ).to(eq(0))
    expect(device.reset_address).to(eq(0x3800))
    expect(cpu.pc).to(eq(0x3800))
    expect(cpu.next_pc).to(eq(0x3800))

    # 0xd9: BOOTRST = 1 (unprogrammed) -> 0
    fuses.set([0x62, 0xd9, 0xff])
    expect(fuses.bootrst?).to(be(false))
    expect(device.reset_address).to(eq(0))
    expect(cpu.pc).to(eq(0))
    expect(cpu.next_pc).to(eq(0))
  end

  it "initializes CLKPR CLKPS bits based on CKDIV8 fuse" do
    # Default LOW fuse is 0x62 (CKDIV8 is programmed / 0) -> CLKPS = 0b0011 (3)
    expect(fuses.ckdiv8?).to(be(true))
    expect(cpu.CLKPR.CLKPS0).to(be(true))
    expect(cpu.CLKPR.CLKPS1).to(be(true))
    expect(cpu.CLKPR.CLKPS2).to(be(false))
    expect(cpu.CLKPR.CLKPS3).to(be(false))
    expect(cpu.CLKPR.value).to(eq(0x03))

    # When CKDIV8 is unprogrammed (1), e.g. LOW = 0xe2 -> CLKPS = 0b0000 (0)
    fuses.set([0xe2, 0xd9, 0xff])
    expect(fuses.ckdiv8?).to(be(false))
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
