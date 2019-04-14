require 'shared_examples_for_opcode'

RSpec.describe AVR::Opcode, :sbci do
  device = AVR::Device::Atmel_ATmega328p.new
  cpu = device.cpu

  include_examples "opcode", :sbci, cpu.r0, 1

  i = cpu.instruction(0, :sbci, cpu.r0, 1)

  it "subtracts correctly" do
    cpu.reset_to_clean_state
    cpu.r0 = 2
    i.execute
    expect(cpu.r0.value).to be 1
  end

  it "does not set the carry flag without overflow" do
    cpu.reset_to_clean_state
    cpu.r0 = 1
    i.execute
    expect(cpu.sreg.C).to be false
  end

  it "overflows to zero and sets the carry flag" do
    cpu.reset_to_clean_state
    cpu.r0 = 0
    i.execute
    expect(cpu.r0.value).to be 255
    expect(cpu.sreg.C).to be true
  end

  it "subtracts the carry flag" do
    cpu.reset_to_clean_state
    cpu.r0 = 2
    cpu.sreg.C = true
    i.execute
    expect(cpu.r0.value).to be 0
    expect(cpu.sreg.C).to be false
  end
end