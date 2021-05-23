# typed: false
require "shared_examples_for_opcode"

RSpec.describe([AVR::Opcode, :sbc]) do
  let(:i) { cpu.instruction(:sbc, cpu.r0, cpu.r1) }

  include_examples "opcode", :sbc

  it "subtracts correctly" do
    cpu.r0 = 3
    cpu.r1 = 2
    i.execute
    expect(cpu.r0.value).to(eq(1))
    expect(cpu.r1.value).to(eq(2))
  end

  it "does not set the carry flag without overflow" do
    cpu.r0 = 1
    cpu.r1 = 1
    i.execute
    expect(cpu.sreg.C).to(be(false))
  end

  it "overflows to zero and sets the carry flag" do
    cpu.r0 = 0
    cpu.r1 = 1
    i.execute
    expect(cpu.r0.value).to(eq(255))
    expect(cpu.sreg.C).to(be(true))
  end

  it "subtracts the carry flag" do
    cpu.r0 = 3
    cpu.r1 = 2
    cpu.sreg.C = true
    i.execute
    expect(cpu.r0.value).to(eq(0))
    expect(cpu.sreg.C).to(be(false))
  end
end
