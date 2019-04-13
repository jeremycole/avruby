require 'shared_examples_for_opcode'

RSpec.describe AVR::Opcode, :adiw do
  device = AVR::Device::Atmel_ATmega328p.new
  cpu = device.cpu

  include_examples "opcode", :adiw, cpu.Z, 1

  i = cpu.instruction(0, :adiw, cpu.Z, 1)

  it "adds correctly" do
    cpu.reset_to_clean_state
    cpu.Z = 0
    i.execute
    expect(cpu.Z.value).to be 1
  end

  it "does not set the carry flag without overflow" do
    cpu.reset_to_clean_state
    cpu.Z = 0xfffe
    i.execute
    expect(cpu.sreg.C).to be false
  end

  it "overflows to zero and sets the carry flag" do
    cpu.reset_to_clean_state
    cpu.Z = 0xffff
    i.execute
    expect(cpu.Z.value).to be 0
    expect(cpu.sreg.C).to be true
  end

  it "does not add the carry flag" do
    cpu.reset_to_clean_state
    cpu.Z = 0
    cpu.sreg.C = true
    i.execute
    expect(cpu.Z.value).to be 1
    expect(cpu.sreg.C).to be false
  end
end