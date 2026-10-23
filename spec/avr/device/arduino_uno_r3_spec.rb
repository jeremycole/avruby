# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Device::Arduino_Uno_R3) do
  let(:device) { described_class.new }
  let(:cpu) { device.cpu }
  let(:fuses) { device.fuses }

  it "has device_name 'Arduino Uno R3'" do
    expect(described_class.device_name).to(eq("Arduino Uno R3"))
  end

  it "has expected fuse default values" do
    expect(device.fuse_default_values).to(eq(
      LOW: 0xff,
      HIGH: 0xde,
      EXTENDED: 0x05,
    ))
    expect(fuses.LOW.value).to(eq(0xff))
    expect(fuses.HIGH.value).to(eq(0xde))
    expect(fuses.EXTENDED.value).to(eq(0x05))
  end

  it "starts at bootloader reset address (0x3F00) with default fuses" do
    expect(fuses.bootrst?).to(be(true))
    expect(fuses.BOOTSZ).to(eq(3))
    expect(device.boot_size_map[3]).to(eq(256))
    expect(device.reset_address).to(eq(0x3F00))
    expect(cpu.pc).to(eq(0x3F00))
    expect(cpu.next_pc).to(eq(0x3F00))
  end

  it "initializes CLKPR with CKDIV8 unprogrammed (0x00)" do
    expect(fuses.ckdiv8?).to(be(false))
    expect(cpu.CLKPR.value).to(eq(0x00))
  end

  it "inherits memory sizes and register mappings from Atmel_ATmega328p" do
    expect(device.flash_size).to(eq(32_768))
    expect(device.sram_size).to(eq(2048))
    expect(device.eeprom_size).to(eq(1024))
    expect(device.register_count).to(eq(32))
  end
end
