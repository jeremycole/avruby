# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Memory::Fuses) do
  let(:device) { AVR::Device::Atmel_ATmega328p.new }
  let(:cpu) { device.cpu }
  let(:fuses) { device.fuses }

  it "is defined and is a subclass of AVR::Memory::MemoryByteBacked" do
    expect(described_class).to(be_an_instance_of(Class))
    expect(described_class.superclass).to(eq(AVR::Memory::MemoryByteBacked))
  end

  it "is available in the device and cpu" do
    expect(device.fuses).to(be_an_instance_of(described_class))
    expect(cpu.fuses).to(be(device.fuses))
  end

  it "initializes from a device definition with standard default fuse values" do
    expect(fuses[0].value).to(eq(0x62))
    expect(fuses[1].value).to(eq(0xd9))
    expect(fuses[2].value).to(eq(0xff))
  end

  it "has correct named bit values for ATmega328p fuse defaults" do
    # Low
    expect(fuses.bits[:CKSEL0]).to(be(0))
    expect(fuses.bits[:CKSEL1]).to(be(1))
    expect(fuses.bits[:CKSEL2]).to(be(0))
    expect(fuses.bits[:CKSEL3]).to(be(0))
    expect(fuses.bits[:SUT0]).to(be(0))
    expect(fuses.bits[:SUT1]).to(be(1))
    expect(fuses.bits[:CKOUT]).to(be(1))
    expect(fuses.bits[:CKDIV8]).to(be(0))

    # High
    expect(fuses.bits[:BOOTRST]).to(be(1))
    expect(fuses.bits[:BOOTSZ0]).to(be(0))
    expect(fuses.bits[:BOOTSZ1]).to(be(0))
    expect(fuses.bits[:EESAVE]).to(be(1))
    expect(fuses.bits[:WDTON]).to(be(1))
    expect(fuses.bits[:SPIEN]).to(be(0))
    expect(fuses.bits[:DWEN]).to(be(1))
    expect(fuses.bits[:RSTDISBL]).to(be(1))

    # Extended
    expect(fuses.bits[:BODLEVEL0]).to(be(1))
    expect(fuses.bits[:BODLEVEL1]).to(be(1))
    expect(fuses.bits[:BODLEVEL2]).to(be(1))
  end

  it "allows setting fuses from an array of integers" do
    fuses.set([0x11, 0x22, 0x33])
    expect(fuses[0].value).to(eq(0x11))
    expect(fuses[1].value).to(eq(0x22))
    expect(fuses[2].value).to(eq(0x33))
  end

  it "allows resetting fuses to default values" do
    fuses.set([0x11, 0x22, 0x33])

    fuses.reset_to_defaults
    expect(fuses[0].value).to(eq(0x62))
    expect(fuses[1].value).to(eq(0xd9))
    expect(fuses[2].value).to(eq(0xff))
  end

  it "allows watching fuse memory changes" do
    observed = []
    device.fuses.watch do |memory_byte, old_value, new_value|
      observed << [memory_byte.address, old_value, new_value]
    end

    fuses[0].value = 0xff
    expect(observed).to(eq([[0, 0x62, 0xff]]))
  end

  it "extracts 0-based sequentially-numbered multi-bit fuses into composite Integer values" do
    # Default LOW: 0x62 (CKSEL3..0 = 0010b = 2, SUT1..0 = 10b = 2)
    expect(fuses.composites[:CKSEL]).to(eq(2))
    expect(fuses.composites[:SUT]).to(eq(2))

    # Default HIGH: 0xd9 (BOOTSZ1..0 = 00b = 0)
    expect(fuses.composites[:BOOTSZ]).to(eq(0))

    # Default EXTENDED: 0xff (BODLEVEL2..0 = 111b = 7)
    expect(fuses.composites[:BODLEVEL]).to(eq(7))
  end

  it "does not extract a composite Integer values for non-composite fuses ending in a number e.g. CKDIV8" do
    expect(fuses).not_to(respond_to(:CKDIV))
  end
end
