require 'shared_examples_for_opcode'

RSpec.describe AVR::Opcode, :add do
  device = AVR::Device::Atmel_ATmega328p.new
  cpu = device.cpu

  include_examples "opcode", :add, cpu.r0, cpu.r1

  i = cpu.instruction(0, :add, cpu.r0, cpu.r1)

  it "adds correctly" do
    cpu.reset_to_clean_state
    cpu.r0 = 0
    cpu.r1 = 1
    i.execute
    expect(cpu.r0.value).to be 1
    expect(cpu.r1.value).to be 1
  end

  it "does not set the carry flag without overflow" do
    cpu.reset_to_clean_state
    cpu.r0 = 0
    cpu.r1 = 1
    i.execute
    expect(cpu.sreg.C).to be false
  end

  it "overflows to zero and sets the carry flag" do
    cpu.reset_to_clean_state
    cpu.r0 = 255
    cpu.r1 = 1
    i.execute
    expect(cpu.r0.value).to be 0
    expect(cpu.sreg.C).to be true
  end

  it "does not add the carry flag" do
    cpu.reset_to_clean_state
    cpu.r0 = 0
    cpu.r1 = 1
    cpu.sreg.C = true
    i.execute
    expect(cpu.r0.value).to be 1
    expect(cpu.sreg.C).to be false
  end
end