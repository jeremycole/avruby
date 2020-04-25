require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :sub] do
  include_examples "opcode", :sub

  let(:i) { cpu.instruction(:sub, cpu.r0, cpu.r1) }

  it "subtracts correctly" do
    cpu.r0 = 3
    cpu.r1 = 2
    i.execute
    expect(cpu.r0.value).to eq 1
    expect(cpu.r1.value).to eq 2
  end

  it "does not set the carry flag without overflow" do
    cpu.r0 = 1
    cpu.r1 = 1
    i.execute
    expect(cpu.sreg.C).to eq false
  end

  it "overflows to zero and sets the carry flag" do
    cpu.r0 = 0
    cpu.r1 = 1
    i.execute
    expect(cpu.r0.value).to eq 255
    expect(cpu.sreg.C).to be true
  end

  it "does not subtract the carry flag" do
    cpu.r0 = 3
    cpu.r1 = 2
    cpu.sreg.C = true
    i.execute
    expect(cpu.r0.value).to eq 1
    expect(cpu.sreg.C).to be false
  end
end