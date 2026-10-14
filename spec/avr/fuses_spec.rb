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

  it "allows resetting fuses to default values" do
    fuses.LOW.value = 0x00
    fuses.HIGH.value = 0x00
    fuses.EXTENDED.value = 0x00
    expect(fuses.LOW.value).to(eq(0x00))

    fuses.reset
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
end
