require 'shared_examples_for_opcode'

RSpec.describe AVR::Opcode, :swap do
  device = AVR::Device::Atmel_ATmega328p.new
  cpu = device.cpu

  include_examples "opcode", :swap, cpu.r0

  i = cpu.instruction(0, :swap, cpu.r0)

  it "performs nibble swap correctly" do
    cpu.reset_to_clean_state
    cpu.r0 = 0xf0
    i.execute
    expect(cpu.r0.value).to be 0x0f
    i.execute
    expect(cpu.r0.value).to be 0xf0
  end
end