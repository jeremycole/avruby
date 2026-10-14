# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Device) do
  describe "Atmel_ATmega328p" do
    let(:device) { AVR::Device::Atmel_ATmega328p.new }
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

    it "has all expected data memory map register entries" do
      expect(device.data_memory_map[:TIFR0]).to(eq(0x0035))
      expect(device.data_memory_map[:TIFR1]).to(eq(0x0036))
      expect(device.data_memory_map[:TIFR2]).to(eq(0x0037))
      expect(device.data_memory_map[:WDTCSR]).to(eq(0x0060))
      expect(device.data_memory_map[:CLKPR]).to(eq(0x0061))
      expect(device.data_memory_map[:PRR]).to(eq(0x0064))
      expect(device.data_memory_map[:OSCCAL]).to(eq(0x0066))
      expect(device.data_memory_map[:PCICR]).to(eq(0x0068))
      expect(device.data_memory_map[:EICRA]).to(eq(0x0069))
      expect(device.data_memory_map[:PCMSK0]).to(eq(0x006b))
      expect(device.data_memory_map[:PCMSK1]).to(eq(0x006c))
      expect(device.data_memory_map[:PCMSK2]).to(eq(0x006d))
      expect(device.data_memory_map[:TIMSK0]).to(eq(0x006e))
      expect(device.data_memory_map[:TIMSK1]).to(eq(0x006f))
      expect(device.data_memory_map[:TIMSK2]).to(eq(0x0070))
      expect(device.data_memory_map[:ADCL]).to(eq(0x0078))
      expect(device.data_memory_map[:ADCH]).to(eq(0x0079))
      expect(device.data_memory_map[:ADCSRA]).to(eq(0x007a))
      expect(device.data_memory_map[:ADCSRB]).to(eq(0x007b))
      expect(device.data_memory_map[:ADMUX]).to(eq(0x007c))
      expect(device.data_memory_map[:DIDR0]).to(eq(0x007e))
      expect(device.data_memory_map[:DIDR1]).to(eq(0x007f))
      expect(device.data_memory_map[:TCCR1A]).to(eq(0x0080))
      expect(device.data_memory_map[:TCCR1B]).to(eq(0x0081))
      expect(device.data_memory_map[:TCCR1C]).to(eq(0x0082))
      expect(device.data_memory_map[:TCNT1L]).to(eq(0x0084))
      expect(device.data_memory_map[:TCNT1H]).to(eq(0x0085))
      expect(device.data_memory_map[:ICR1L]).to(eq(0x0086))
      expect(device.data_memory_map[:ICR1H]).to(eq(0x0087))
      expect(device.data_memory_map[:OCR1AL]).to(eq(0x0088))
      expect(device.data_memory_map[:OCR1AH]).to(eq(0x0089))
      expect(device.data_memory_map[:OCR1BL]).to(eq(0x008a))
      expect(device.data_memory_map[:OCR1BH]).to(eq(0x008b))
      expect(device.data_memory_map[:TCCR2A]).to(eq(0x00b0))
      expect(device.data_memory_map[:TCCR2B]).to(eq(0x00b1))
      expect(device.data_memory_map[:TCNT2]).to(eq(0x00b2))
      expect(device.data_memory_map[:OCR2A]).to(eq(0x00b3))
      expect(device.data_memory_map[:OCR2B]).to(eq(0x00b4))
      expect(device.data_memory_map[:ASSR]).to(eq(0x00b6))
      expect(device.data_memory_map[:TWBR]).to(eq(0x00b8))
      expect(device.data_memory_map[:TWSR]).to(eq(0x00b9))
      expect(device.data_memory_map[:TWAR]).to(eq(0x00ba))
      expect(device.data_memory_map[:TWDR]).to(eq(0x00bb))
      expect(device.data_memory_map[:TWCR]).to(eq(0x00bc))
      expect(device.data_memory_map[:TWAMR]).to(eq(0x00bd))
      expect(device.data_memory_map[:UCSR0A]).to(eq(0x00c0))
      expect(device.data_memory_map[:UCSR0B]).to(eq(0x00c1))
      expect(device.data_memory_map[:UCSR0C]).to(eq(0x00c2))
      expect(device.data_memory_map[:UBRR0L]).to(eq(0x00c4))
      expect(device.data_memory_map[:UBRR0H]).to(eq(0x00c5))
      expect(device.data_memory_map[:UDR0]).to(eq(0x00c6))
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
  end

  describe "Atmel_ATmega644pa" do
    let(:device) { AVR::Device::Atmel_ATmega644pa.new }
    let(:cpu) { device.cpu }
    let(:fuses) { device.fuses }

    it "has correct boot size map" do
      expect(device.boot_size_map).to(eq(
        {
          3 => 512,
          2 => 1024,
          1 => 2048,
          0 => 4096,
        }
      ))
    end

    it "has all expected data memory map register entries" do
      expect(device.data_memory_map[:PINA]).to(eq(0x0020))
      expect(device.data_memory_map[:DDRA]).to(eq(0x0021))
      expect(device.data_memory_map[:PORTA]).to(eq(0x0022))
      expect(device.data_memory_map[:OCDR]).to(eq(0x0051))
      expect(device.data_memory_map[:WDTCSR]).to(eq(0x0060))
      expect(device.data_memory_map[:CLKPR]).to(eq(0x0061))
      expect(device.data_memory_map[:PRR0]).to(eq(0x0064))
      expect(device.data_memory_map[:OSCCAL]).to(eq(0x0066))
      expect(device.data_memory_map[:PCICR]).to(eq(0x0068))
      expect(device.data_memory_map[:EICRA]).to(eq(0x0069))
      expect(device.data_memory_map[:PCMSK0]).to(eq(0x006b))
      expect(device.data_memory_map[:PCMSK1]).to(eq(0x006c))
      expect(device.data_memory_map[:PCMSK2]).to(eq(0x006d))
      expect(device.data_memory_map[:TIMSK0]).to(eq(0x006e))
      expect(device.data_memory_map[:TIMSK1]).to(eq(0x006f))
      expect(device.data_memory_map[:TIMSK2]).to(eq(0x0070))
      expect(device.data_memory_map[:PCMSK3]).to(eq(0x0073))
      expect(device.data_memory_map[:ADCL]).to(eq(0x0078))
      expect(device.data_memory_map[:ADCH]).to(eq(0x0079))
      expect(device.data_memory_map[:ADCSRA]).to(eq(0x007a))
      expect(device.data_memory_map[:ADCSRB]).to(eq(0x007b))
      expect(device.data_memory_map[:ADMUX]).to(eq(0x007c))
      expect(device.data_memory_map[:DIDR0]).to(eq(0x007e))
      expect(device.data_memory_map[:DIDR1]).to(eq(0x007f))
      expect(device.data_memory_map[:TCCR1A]).to(eq(0x0080))
      expect(device.data_memory_map[:TCCR1B]).to(eq(0x0081))
      expect(device.data_memory_map[:TCCR1C]).to(eq(0x0082))
      expect(device.data_memory_map[:TCNT1L]).to(eq(0x0084))
      expect(device.data_memory_map[:TCNT1H]).to(eq(0x0085))
      expect(device.data_memory_map[:ICR1L]).to(eq(0x0086))
      expect(device.data_memory_map[:ICR1H]).to(eq(0x0087))
      expect(device.data_memory_map[:OCR1AL]).to(eq(0x0088))
      expect(device.data_memory_map[:OCR1AH]).to(eq(0x0089))
      expect(device.data_memory_map[:OCR1BL]).to(eq(0x008a))
      expect(device.data_memory_map[:OCR1BH]).to(eq(0x008b))
      expect(device.data_memory_map[:TCCR2A]).to(eq(0x00b0))
      expect(device.data_memory_map[:TCCR2B]).to(eq(0x00b1))
      expect(device.data_memory_map[:TCNT2]).to(eq(0x00b2))
      expect(device.data_memory_map[:OCR2A]).to(eq(0x00b3))
      expect(device.data_memory_map[:OCR2B]).to(eq(0x00b4))
      expect(device.data_memory_map[:ASSR]).to(eq(0x00b6))
      expect(device.data_memory_map[:TWBR]).to(eq(0x00b8))
      expect(device.data_memory_map[:TWSR]).to(eq(0x00b9))
      expect(device.data_memory_map[:TWAR]).to(eq(0x00ba))
      expect(device.data_memory_map[:TWDR]).to(eq(0x00bb))
      expect(device.data_memory_map[:TWCR]).to(eq(0x00bc))
      expect(device.data_memory_map[:TWAMR]).to(eq(0x00bd))
      expect(device.data_memory_map[:UCSR0A]).to(eq(0x00c0))
      expect(device.data_memory_map[:UCSR0B]).to(eq(0x00c1))
      expect(device.data_memory_map[:UCSR0C]).to(eq(0x00c2))
      expect(device.data_memory_map[:UBRR0L]).to(eq(0x00c4))
      expect(device.data_memory_map[:UBRR0H]).to(eq(0x00c5))
      expect(device.data_memory_map[:UDR0]).to(eq(0x00c6))
      expect(device.data_memory_map[:UCSR1A]).to(eq(0x00c8))
      expect(device.data_memory_map[:UCSR1B]).to(eq(0x00c9))
      expect(device.data_memory_map[:UCSR1C]).to(eq(0x00ca))
      expect(device.data_memory_map[:UBRR1L]).to(eq(0x00cc))
      expect(device.data_memory_map[:UBRR1H]).to(eq(0x00cd))
      expect(device.data_memory_map[:UDR1]).to(eq(0x00ce))
    end

    it "calculates correct boot reset address for each BOOTSZ setting" do
      # Flash size = 65536 bytes = 32768 words (0x8000)
      # BOOTSZ = 3 -> 512 words -> 0x7E00 (32256)
      fuses.HIGH.BOOTSZ0 = true
      fuses.HIGH.BOOTSZ1 = true
      expect(fuses.BOOTSZ).to(eq(3))
      expect(device.boot_reset_address).to(eq(0x7E00))

      # BOOTSZ = 2 -> 1024 words -> 0x7C00 (31744)
      fuses.HIGH.BOOTSZ0 = false
      fuses.HIGH.BOOTSZ1 = true
      expect(fuses.BOOTSZ).to(eq(2))
      expect(device.boot_reset_address).to(eq(0x7C00))

      # BOOTSZ = 1 -> 2048 words -> 0x7800 (30720)
      fuses.HIGH.BOOTSZ0 = true
      fuses.HIGH.BOOTSZ1 = false
      expect(fuses.BOOTSZ).to(eq(1))
      expect(device.boot_reset_address).to(eq(0x7800))

      # BOOTSZ = 0 -> 4096 words -> 0x7000 (28672)
      fuses.HIGH.BOOTSZ0 = false
      fuses.HIGH.BOOTSZ1 = false
      expect(fuses.BOOTSZ).to(eq(0))
      expect(device.boot_reset_address).to(eq(0x7000))
    end
  end
end
