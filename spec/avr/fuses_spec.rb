# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Fuses) do
  let(:device) { AVR::Device::Atmel_ATmega328p.new }
  let(:cpu) { device.cpu }
  let(:fuses) { device.fuses }

  it "is defined and is a subclass of AVR::Memory" do
    expect(described_class).to(be_an_instance_of(Class))
    expect(described_class.superclass).to(eq(AVR::Memory))
  end

  it "is available in the device and cpu" do
    expect(device.fuses).to(be_an_instance_of(described_class))
    expect(cpu.fuses).to(be(device.fuses))
  end

  it "has low, high, and extended fuse registers on ATmega328p" do
    expect(fuses.LOW).to(be_an_instance_of(AVR::MemoryByteRegisterWithNamedBits))
    expect(fuses.HIGH).to(be_an_instance_of(AVR::MemoryByteRegisterWithNamedBits))
    expect(fuses.EXTENDED).to(be_an_instance_of(AVR::MemoryByteRegisterWithNamedBits))
  end

  it "provides lowercase alias methods for fuse registers" do
    expect(fuses.low).to(be(fuses.LOW))
    expect(fuses.high).to(be(fuses.HIGH))
    expect(fuses.extended).to(be(fuses.EXTENDED))
  end

  it "supports indexing by Integer, Symbol, and String" do
    expect(fuses[0]).to(be(fuses.memory[0]))
    expect(fuses[:LOW]).to(be(fuses.LOW))
    expect(fuses[:low]).to(be(fuses.LOW))
    expect(fuses["HIGH"]).to(be(fuses.HIGH))
    expect(fuses["high"]).to(be(fuses.HIGH))
    expect(fuses[:EXTENDED]).to(be(fuses.EXTENDED))
  end

  it "initializes ATmega328p with standard default fuse values" do
    expect(fuses.LOW.value).to(eq(0x62))
    expect(fuses.HIGH.value).to(eq(0xd9))
    expect(fuses.EXTENDED.value).to(eq(0xff))
  end

  it "initializes ATmega644pa with standard default fuse values" do
    mega644 = AVR::Device::Atmel_ATmega644pa.new
    expect(mega644.fuses.LOW.value).to(eq(0x62))
    expect(mega644.fuses.HIGH.value).to(eq(0x99))
    expect(mega644.fuses.EXTENDED.value).to(eq(0xff))
  end

  it "initializes ATmega32u4 with standard default fuse values" do
    mega32u4 = AVR::Device::Atmel_ATmega32u4.new
    expect(mega32u4.fuses.LOW.value).to(eq(0x5e))
    expect(mega32u4.fuses.HIGH.value).to(eq(0x99))
    expect(mega32u4.fuses.EXTENDED.value).to(eq(0xf3))
  end

  it "has correct named bit values for ATmega328p low fuse default (0x62)" do
    expect(fuses.LOW.CKSEL0).to(be(false))
    expect(fuses.LOW.CKSEL1).to(be(true))
    expect(fuses.LOW.CKSEL2).to(be(false))
    expect(fuses.LOW.CKSEL3).to(be(false))
    expect(fuses.LOW.SUT0).to(be(false))
    expect(fuses.LOW.SUT1).to(be(true))
    expect(fuses.LOW.CKOUT).to(be(true))
    expect(fuses.LOW.CKDIV8).to(be(false))
  end

  it "has correct named bit values for ATmega328p high fuse default (0xd9)" do
    expect(fuses.HIGH.BOOTRST).to(be(true))
    expect(fuses.HIGH.BOOTSZ0).to(be(false))
    expect(fuses.HIGH.BOOTSZ1).to(be(false))
    expect(fuses.HIGH.EESAVE).to(be(true))
    expect(fuses.HIGH.WDTON).to(be(true))
    expect(fuses.HIGH.SPIEN).to(be(false))
    expect(fuses.HIGH.DWEN).to(be(true))
    expect(fuses.HIGH.RSTDISBL).to(be(true))
  end

  it "has correct named bit values for ATmega644pa high fuse default (0x99)" do
    mega644 = AVR::Device::Atmel_ATmega644pa.new
    expect(mega644.fuses.HIGH.BOOTRST).to(be(true))
    expect(mega644.fuses.HIGH.BOOTSZ0).to(be(false))
    expect(mega644.fuses.HIGH.BOOTSZ1).to(be(false))
    expect(mega644.fuses.HIGH.EESAVE).to(be(true))
    expect(mega644.fuses.HIGH.WDTON).to(be(true))
    expect(mega644.fuses.HIGH.SPIEN).to(be(false))
    expect(mega644.fuses.HIGH.JTAGEN).to(be(false))
    expect(mega644.fuses.HIGH.OCDEN).to(be(true))
  end

  it "has correct named bit values for ATmega32u4 extended fuse default (0xf3)" do
    mega32u4 = AVR::Device::Atmel_ATmega32u4.new
    expect(mega32u4.fuses.EXTENDED.BODLEVEL0).to(be(true))
    expect(mega32u4.fuses.EXTENDED.BODLEVEL1).to(be(true))
    expect(mega32u4.fuses.EXTENDED.BODLEVEL2).to(be(false))
    expect(mega32u4.fuses.EXTENDED.HWBE).to(be(false))
  end

  it "has correct named bit values for extended fuse default (0xff)" do
    expect(fuses.EXTENDED.BODLEVEL0).to(be(true))
    expect(fuses.EXTENDED.BODLEVEL1).to(be(true))
    expect(fuses.EXTENDED.BODLEVEL2).to(be(true))
  end

  it "allows mutating named bits and reflects changes in memory byte" do
    fuses.LOW.CKDIV8 = true
    expect(fuses.LOW.CKDIV8).to(be(true))
    expect(fuses.LOW.value).to(eq(0xe2))
    expect(fuses.memory[0].value).to(eq(0xe2))

    fuses.LOW.CKDIV8 = false
    expect(fuses.LOW.CKDIV8).to(be(false))
    expect(fuses.LOW.value).to(eq(0x62))
    expect(fuses.memory[0].value).to(eq(0x62))
  end

  it "allows setting fuses from an array of integers" do
    fuses.set([0x11, 0x22, 0x33])
    expect(fuses.LOW.value).to(eq(0x11))
    expect(fuses.HIGH.value).to(eq(0x22))
    expect(fuses.EXTENDED.value).to(eq(0x33))
  end

  it "allows resetting fuses to default values" do
    fuses.LOW.value = 0x00
    fuses.HIGH.value = 0x00
    fuses.EXTENDED.value = 0x00
    expect(fuses.LOW.value).to(eq(0x00))

    fuses.reset_to_defaults
    expect(fuses.LOW.value).to(eq(0x62))
    expect(fuses.HIGH.value).to(eq(0xd9))
    expect(fuses.EXTENDED.value).to(eq(0xff))
  end

  it "allows watching fuse memory changes" do
    observed = []
    device.fuses.watch do |memory_byte, old_value, new_value|
      observed << [memory_byte.address, old_value, new_value]
    end

    fuses.LOW.value = 0xff
    expect(observed).to(eq([[0, 0x62, 0xff]]))
  end

  it "defines predicate methods reflecting reversed fuse logic (0 = true/enabled)" do
    # Low fuse: 0x62 (0b01100010) -> bits 0, 2, 3, 4, 7 are 0 (true), bits 1, 5, 6 are 1 (false)
    expect(fuses.cksel0?).to(be(true))
    expect(fuses.cksel1?).to(be(false))
    expect(fuses.cksel2?).to(be(true))
    expect(fuses.cksel3?).to(be(true))
    expect(fuses.sut0?).to(be(true))
    expect(fuses.sut1?).to(be(false))
    expect(fuses.ckout?).to(be(false))
    expect(fuses.ckdiv8?).to(be(true))

    # Also supports uppercase predicate methods
    expect(fuses.CKOUT?).to(be(false))
    expect(fuses.CKDIV8?).to(be(true))

    # High fuse: 0xd9 (0b11011001) -> bits 1, 2, 5 are 0 (true), bits 0, 3, 4, 6, 7 are 1 (false)
    expect(fuses.bootrst?).to(be(false))
    expect(fuses.bootsz0?).to(be(true))
    expect(fuses.bootsz1?).to(be(true))
    expect(fuses.eesave?).to(be(false))
    expect(fuses.wdton?).to(be(false))
    expect(fuses.spien?).to(be(true))
    expect(fuses.dwen?).to(be(false))
    expect(fuses.rstdisbl?).to(be(false))

    # Extended fuse: 0xff (0b11111111) -> bits 0..2 are 1 (false)
    expect(fuses.bodlevel0?).to(be(false))
    expect(fuses.bodlevel1?).to(be(false))
    expect(fuses.bodlevel2?).to(be(false))

    # Changing a fuse bit updates predicate methods
    fuses.LOW.CKOUT = false # 0 bit -> enabled
    expect(fuses.ckout?).to(be(true))
    expect(fuses.CKOUT?).to(be(true))

    fuses.LOW.CKOUT = true # 1 bit -> disabled
    expect(fuses.ckout?).to(be(false))
    expect(fuses.CKOUT?).to(be(false))
  end

  it "extracts 0-based sequentially-numbered multi-bit fuses into Integer values" do
    # Default LOW: 0x62 (CKSEL3..0 = 0010b = 2, SUT1..0 = 10b = 2)
    expect(fuses.CKSEL).to(eq(2))
    expect(fuses.cksel).to(eq(2))
    expect(fuses.LOW.CKSEL).to(eq(2))
    expect(fuses.LOW.cksel).to(eq(2))

    expect(fuses.SUT).to(eq(2))
    expect(fuses.sut).to(eq(2))
    expect(fuses.LOW.SUT).to(eq(2))
    expect(fuses.LOW.sut).to(eq(2))

    # Default HIGH: 0xd9 (BOOTSZ1..0 = 00b = 0)
    expect(fuses.BOOTSZ).to(eq(0))
    expect(fuses.bootsz).to(eq(0))
    expect(fuses.HIGH.BOOTSZ).to(eq(0))
    expect(fuses.HIGH.bootsz).to(eq(0))

    # Default EXTENDED: 0xff (BODLEVEL2..0 = 111b = 7)
    expect(fuses.BODLEVEL).to(eq(7))
    expect(fuses.bodlevel).to(eq(7))
    expect(fuses.EXTENDED.BODLEVEL).to(eq(7))
    expect(fuses.EXTENDED.bodlevel).to(eq(7))

    # Modifying bits dynamically updates multi-bit fuse value
    fuses.LOW.CKSEL0 = true
    fuses.LOW.CKSEL1 = true
    fuses.LOW.CKSEL2 = false
    fuses.LOW.CKSEL3 = true
    expect(fuses.CKSEL).to(eq(11)) # 1011b = 11

    fuses.HIGH.BOOTSZ0 = true
    fuses.HIGH.BOOTSZ1 = true
    expect(fuses.BOOTSZ).to(eq(3)) # 11b = 3

    fuses.EXTENDED.BODLEVEL0 = false
    fuses.EXTENDED.BODLEVEL1 = true
    fuses.EXTENDED.BODLEVEL2 = false
    expect(fuses.BODLEVEL).to(eq(2)) # 010b = 2

    # Does not create multi-bit helper for CKDIV8
    expect(fuses).not_to(respond_to(:CKDIV))
    expect(fuses).not_to(respond_to(:ckdiv))
    expect(fuses.LOW).not_to(respond_to(:CKDIV))
    expect(fuses.LOW).not_to(respond_to(:ckdiv))
  end
end
