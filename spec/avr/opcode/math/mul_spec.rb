# typed: false
require "shared_examples_for_opcode"

RSpec.describe([AVR::Opcode, :mul]) do
  let(:i) { cpu.instruction(:mul, cpu.r16, cpu.r17) }

  include_examples "opcode", :mul

  it "performs multiplication correctly" do
    cpu.r16 = 17
    cpu.r17 = 19
    i.execute
    expect(cpu.r0.value).to(eq(0x43))
    expect(cpu.r1.value).to(eq(0x01))
  end

  it "sets the carry bit when appropriate" do
    cpu.r16 = 255
    cpu.r17 = 255
    i.execute
    expect(cpu.r0.value).to(eq(0x01))
    expect(cpu.r1.value).to(eq(0xfe))
    expect(cpu.sreg.C).to(eq(true))
  end

  it "sets the Z bit when the result is zero" do
    cpu.r16 = 0
    cpu.r17 = 123
    i.execute
    expect(cpu.sreg.Z).to(eq(true))
  end
end
