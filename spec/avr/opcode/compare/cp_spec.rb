require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :cp] do
  include_examples "opcode", :cp

  let(:i) { cpu.instruction(:cp, cpu.r0, cpu.r1) }

  it "compares r0 == r1" do
    cpu.r0 = 5
    cpu.r1 = 5
    i.execute
    expect(cpu.sreg.Z).to be true
    expect(cpu.sreg.C).to be false
  end

  it "compares r0 < r1" do
    cpu.r0 = 5
    cpu.r1 = 6
    i.execute
    expect(cpu.sreg.Z).to be false
    expect(cpu.sreg.C).to be true
  end

  it "compares r0 > r1" do
    cpu.r0 = 6
    cpu.r1 = 5
    i.execute
    expect(cpu.sreg.Z).to be false
    expect(cpu.sreg.C).to be false
  end
end
