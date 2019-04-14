require 'shared_examples_for_opcode'

RSpec.describe AVR::Opcode, :ori do
  device = AVR::Device::Atmel_ATmega328p.new
  cpu = device.cpu

  include_examples "opcode", :ori, cpu.r0, 0b01101100

  i = cpu.instruction(0, :ori, cpu.r0, 0b01101100)

  it "performs bitwise OR correctly" do
    cpu.reset_to_clean_state
    cpu.r0 = 0b01010101
    i.execute
    expect(cpu.r0.value).to be 0b01111101
  end
end