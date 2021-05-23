# typed: false
require "shared_examples_for_opcode"

RSpec.describe([AVR::Opcode, :com]) do
  let(:i) { cpu.instruction(:com, cpu.r0) }

  include_examples "opcode", :com

  it "performs ones complement correctly" do
    cpu.r0 = 0xaa
    i.execute
    expect(cpu.r0.value).to(eq(0x55))
    i.execute
    expect(cpu.r0.value).to(eq(0xaa))
  end
end
