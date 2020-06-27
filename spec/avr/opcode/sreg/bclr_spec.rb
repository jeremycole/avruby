# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :bclr] do
  include_examples 'opcode', :bclr

  it 'sets the correct SREG bit' do
    cpu.sreg.value = 0xff
    cpu.instruction(:bclr, :Z).execute
    expect(cpu.sreg.I).to be true
    expect(cpu.sreg.T).to be true
    expect(cpu.sreg.H).to be true
    expect(cpu.sreg.S).to be true
    expect(cpu.sreg.V).to be true
    expect(cpu.sreg.N).to be true
    expect(cpu.sreg.Z).to be false
    expect(cpu.sreg.C).to be true
  end
end
