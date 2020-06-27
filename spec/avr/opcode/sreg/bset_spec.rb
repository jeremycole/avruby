# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :bset] do
  include_examples 'opcode', :bset

  it 'sets the correct SREG bit' do
    cpu.sreg.value = 0x00
    cpu.instruction(:bset, :Z).execute
    expect(cpu.sreg.I).to be false
    expect(cpu.sreg.T).to be false
    expect(cpu.sreg.H).to be false
    expect(cpu.sreg.S).to be false
    expect(cpu.sreg.V).to be false
    expect(cpu.sreg.N).to be false
    expect(cpu.sreg.Z).to be true
    expect(cpu.sreg.C).to be false
  end
end
