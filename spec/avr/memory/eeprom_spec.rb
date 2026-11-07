# typed: false

RSpec.describe(AVR::Memory::EEPROM) do
  let(:device) { AVR::Device::Atmel_ATmega328p.new }
  let(:cpu) { device.cpu }

  it "is defined and is a subclass of AVR::Memory::MemoryByteBacked" do
    expect(described_class).to(be_an_instance_of(Class))
    expect(described_class.superclass).to(eq(AVR::Memory::MemoryByteBacked))
  end

  it "is available in the device" do
    expect(device.eeprom).to(be_an_instance_of(described_class))
  end

  it "has low and high address registers" do
    expect(cpu.EEARL).to(be_an_instance_of(AVR::MemoryByteRegister))
    expect(cpu.EEARH).to(be_an_instance_of(AVR::MemoryByteRegister))
  end

  it "has a data register" do
    expect(cpu.EEDR).to(be_an_instance_of(AVR::MemoryByteRegister))
  end

  it "has a control register" do
    expect(cpu.EECR).to(be_an_instance_of(AVR::MemoryByteRegisterWithNamedBits))
  end

  it "can read data from EEPROM" do
    device.eeprom[0xaa].value = 0xaf
    cpu.EEDR.value = 0x00
    cpu.EEARL.value = 0xaa
    cpu.EECR.set(:EERE, 1)
    expect(cpu.EEDR.value).to(eq(0xaf))
    expect(cpu.EECR.get(:EERE)).to(be(0))
  end

  it "clears the EEMPE flag after 4 cycles" do
    5.times do |i|
      cpu.device.flash.set_word(0x0100 + i, 0b0000_0000_0000_0000) # nop
    end
    cpu.instruction(:jmp, AVR::Value.new(0x0100)).execute
    cpu.EECR.set(:EEMPE, 1)
    4.times do
      device.oscillator.tick
      expect(cpu.EECR.get(:EEMPE)).to(be(1))
    end
    device.oscillator.tick
    expect(cpu.EECR.get(:EEMPE)).to(be(0))
  end

  it "can write data to EEPROM" do
    device.eeprom[0xaa].value = 0xff
    cpu.EEDR.value = 0xaf
    cpu.EEARL.value = 0xaa
    cpu.EECR.set(:EEMPE, 1)
    cpu.EECR.set(:EEPE, 1)
    expect(device.eeprom[0xaa].value).to(eq(0xaf))
    expect(cpu.EECR.get(:EEMPE)).to(be(0))
    expect(cpu.EECR.get(:EEPE)).to(be(0))
  end

  it "calls the EE_READY interrupt when ready" do
    device.eeprom[0xaa].value = 0xaf
    cpu.EEDR.value = 0x00
    cpu.EEARL.value = 0xaa
    cpu.EECR.set(:EERIE, 1)
    cpu.sreg.I = 1
    sp_before = cpu.sp.value
    cpu.EECR.set(:EERE, 1)
    expect(sp_before - cpu.sp.value).to(eq(2))
    expect(cpu.sreg.I).to(be(0))
    expect(cpu.next_pc).to(eq(device.interrupt_vector_map[:EE_READY]))
  end
end
