# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :cpc] do
  include_examples 'opcode', :cpc

  let(:i) { cpu.instruction(:cpc, cpu.r0, cpu.r1) }

  it 'compares r0 == r1, Z=1, C=0' do
    cpu.r0 = 5
    cpu.r1 = 5
    cpu.sreg.Z = true
    cpu.sreg.C = false
    i.execute
    expect(cpu.sreg.Z).to be true
    expect(cpu.sreg.C).to be false
  end

  it 'compares r0 < r1, Z=0, C=0' do
    cpu.r0 = 5
    cpu.r1 = 6
    cpu.sreg.Z = false
    cpu.sreg.C = false
    i.execute
    expect(cpu.sreg.Z).to be false
    expect(cpu.sreg.C).to be true
  end

  it 'compares r0 > r1, Z=0, C=0' do
    cpu.r0 = 6
    cpu.r1 = 5
    cpu.sreg.Z = false
    cpu.sreg.C = false
    i.execute
    expect(cpu.sreg.Z).to be false
    expect(cpu.sreg.C).to be false
  end
end
