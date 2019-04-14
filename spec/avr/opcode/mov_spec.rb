require 'shared_examples_for_opcode'

RSpec.describe AVR::Opcode, :mov do
  device = AVR::Device::Atmel_ATmega328p.new
  cpu = device.cpu

  include_examples "opcode", :mov, cpu.r0, cpu.r1

  i = cpu.instruction(0, :mov, cpu.r0, cpu.r1)

  it "performs bitwise AND correctly" do
    cpu.reset_to_clean_state
    cpu.r0 = 0
    cpu.r1 = 1
    i.execute
    expect(cpu.r0.value).to be 1
    expect(cpu.r1.value).to be 1
    cpu.r0 = 1
    cpu.r1 = 0
    i.execute
    expect(cpu.r0.value).to be 0
    expect(cpu.r1.value).to be 0
  end
end