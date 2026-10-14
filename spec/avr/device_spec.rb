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
