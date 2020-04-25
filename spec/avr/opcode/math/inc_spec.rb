require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :inc] do
  include_examples "opcode", :inc

  let(:i) { cpu.instruction(:inc, cpu.r0) }

  it "increments correctly" do
    cpu.r0 = 0
    i.execute
    expect(cpu.r0.value).to eq 1
  end

  it "overflows to zero and does not set the carry flag" do
    cpu.r0 = 255
    i.execute
    expect(cpu.r0.value).to eq 0
    expect(cpu.sreg.C).to be false
  end
end