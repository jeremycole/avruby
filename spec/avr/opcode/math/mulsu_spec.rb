# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :mulsu] do
  include_examples 'opcode', :mulsu

  it 'raises OpcodeNotImplementedError' do
    expect { cpu.instruction(:mulsu, cpu.r16, cpu.r17).execute }.to raise_error(AVR::Opcode::OpcodeNotImplementedError)
  end
end
