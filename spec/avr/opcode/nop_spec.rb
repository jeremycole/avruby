require 'shared_examples_for_opcode'

RSpec.describe AVR::Opcode, :nop do
  device = AVR::Device::Atmel_ATmega328p.new
  cpu = device.cpu

  include_examples "opcode", :nop

  i = cpu.instruction(0, :nop)

  it "does nothing" do
    cpu.reset_to_clean_state
    expect(i.execute).to be_nil
  end
end