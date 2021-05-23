# typed: false
require "shared_examples_for_opcode"

RSpec.describe([AVR::Opcode, :asr]) do
  let(:i) { cpu.instruction(:asr, cpu.r0) }

  include_examples "opcode", :asr

  it "performs right-shift correctly" do
    cpu.r0 = 0b1010
    i.execute
    expect(cpu.r0.value).to(eq(0b101))
    expect(cpu.sreg.C).to(eq(false))
  end

  it "does sign extension" do
    cpu.r0 = 0b10000010
    i.execute
    expect(cpu.r0.value).to(eq(0b11000001))
    expect(cpu.sreg.C).to(eq(false))
  end

  it "sets the carry bit when appropriate" do
    cpu.r0 = 1
    i.execute
    expect(cpu.sreg.C).to(eq(true))
  end

  it "sets the Z bit when the result is zero" do
    cpu.r0 = 1
    i.execute
    expect(cpu.sreg.Z).to(eq(true))
  end
end
