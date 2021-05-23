# typed: false
require "shared_examples_for_opcode"

RSpec.describe([AVR::Opcode, :andi]) do
  include_examples "opcode", :andi

  it "performs bitwise AND correctly" do
    cpu.r0 = 0b01010101
    cpu.instruction(:andi, cpu.r0, AVR::Value.new(0b01101100)).execute
    expect(cpu.r0.value).to(eq(0b01000100))
  end
end
