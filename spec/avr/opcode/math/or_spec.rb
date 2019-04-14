require 'shared_examples_for_opcode'

RSpec.describe AVR::Opcode, :or do
  device = AVR::Device::Atmel_ATmega328p.new
  cpu = device.cpu

  include_examples "opcode", :or, cpu.r0, cpu.r1

  i = cpu.instruction(0, :or, cpu.r0, cpu.r1)

  it "performs bitwise OR correctly" do
    cpu.reset_to_clean_state
    cpu.r0 = 0
    cpu.r1 = 0
    i.execute
    expect(cpu.r0.value).to be 0
    expect(cpu.r1.value).to be 0
    cpu.r0 = 0
    cpu.r1 = 1
    i.execute
    expect(cpu.r0.value).to be 1
    expect(cpu.r1.value).to be 1
    cpu.r0 = 1
    cpu.r1 = 0
    i.execute
    expect(cpu.r0.value).to be 1
    expect(cpu.r1.value).to be 0
    cpu.r0 = 1
    cpu.r1 = 1
    i.execute
    expect(cpu.r0.value).to be 1
    expect(cpu.r1.value).to be 1
    cpu.r0 = 0b01010101
    cpu.r1 = 0b01101100
    i.execute
    expect(cpu.r0.value).to be 0b01111101
  end
end