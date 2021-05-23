# typed: false
require "shared_examples_for_opcode"

RSpec.describe([AVR::Opcode, :bst]) do
  include_examples "opcode", :bst

  it "sets the T flag when the bit from the register is one" do
    cpu.sreg.T = false
    cpu.r0 = 0b00001000
    cpu.instruction(:bst, cpu.r0, AVR::Value.new(3)).execute
    expect(cpu.sreg.T).to(be(true))
  end

  it "clears the T flag when the bit from the register is zero" do
    cpu.sreg.T = true
    cpu.r0 = 0b00000000
    cpu.instruction(:bst, cpu.r0, AVR::Value.new(3)).execute
    expect(cpu.sreg.T).to(be(false))
  end
end
