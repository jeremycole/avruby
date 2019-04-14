require 'shared_examples_for_opcode'

RSpec.describe AVR::Opcode, :andi do
  device = AVR::Device::Atmel_ATmega328p.new
  cpu = device.cpu

  include_examples "opcode", :andi, cpu.r0, 0b01101100

  i = cpu.instruction(0, :andi, cpu.r0, 0b01101100)

  it "performs bitwise AND correctly" do
    cpu.reset_to_clean_state
    cpu.r0 = 0b01010101
    i.execute
    expect(cpu.r0.value).to be 0b01000100
  end
end