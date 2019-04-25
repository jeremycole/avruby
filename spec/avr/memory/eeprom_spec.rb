RSpec.describe AVR::EEPROM do
  before(:all) do
    @device = AVR::Device::Atmel_ATmega328p.new
    @cpu = @device.cpu
  end

  it "is defined and is a subclass of AVR::Memory" do
    expect(AVR::EEPROM).to be_an_instance_of Class
    expect(AVR::EEPROM.superclass).to eq AVR::Memory
  end

  it "is available in the device" do
    expect(@device.eeprom).to be_an_instance_of AVR::EEPROM
  end

  it "has low and high address registers" do
    expect(@cpu.EEARL).to be_an_instance_of AVR::MemoryByteRegister
    expect(@cpu.EEARH).to be_an_instance_of AVR::MemoryByteRegister
  end

  it "has a data register" do
    expect(@cpu.EEDR).to be_an_instance_of AVR::MemoryByteRegister
  end

  it "has a control register" do
    expect(@cpu.EECR).to be_an_instance_of AVR::MemoryByteRegisterWithNamedBits
  end

  it "can read data from EEPROM" do
    @device.eeprom.memory[0xaa].value = 0xaf
    @cpu.EEDR.value = 0x00
    @cpu.EEARL.value = 0xaa
    @cpu.EECR.EERE = true
    expect(@cpu.EEDR.value).to eq 0xaf
    expect(@cpu.EECR.EERE).to be false
  end

  it "clears the EEMPE flag after 4 cycles" do
    5.times do |i|
      @cpu.device.flash.set_word(0x0100 + i, 0b0000_0000_0000_0000) # nop
    end
    @cpu.instruction(:jmp, 0x0100).execute
    @cpu.EECR.EEMPE = true
    4.times do
      @device.oscillator.tick
      expect(@cpu.EECR.EEMPE).to be true
    end
    @device.oscillator.tick
    expect(@cpu.EECR.EEMPE).to be false
  end

  it "can write data to EEPROM" do
    @device.eeprom.memory[0xaa].value = 0xff
    @cpu.EEDR.value = 0xaf
    @cpu.EEARL.value = 0xaa
    @cpu.EECR.EEMPE = true
    @cpu.EECR.EEPE = true
    expect(@device.eeprom.memory[0xaa].value).to eq 0xaf
    expect(@cpu.EECR.EEMPE).to be false
    expect(@cpu.EECR.EEPE).to be false
  end

  it "calls the EE_READY interrupt when ready" do
    @device.eeprom.memory[0xaa].value = 0xaf
    @cpu.EEDR.value = 0x00
    @cpu.EEARL.value = 0xaa
    @cpu.EECR.EERIE = true
    @cpu.sreg.I = true
    sp_before = @cpu.sp.value
    @cpu.EECR.EERE = true
    expect(sp_before - @cpu.sp.value).to eq 2
    expect(@cpu.sreg.I).to be false
    expect(@cpu.next_pc).to eq @device.interrupt_vector_map[:EE_READY]
  end
end
