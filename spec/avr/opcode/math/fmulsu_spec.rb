# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :fmulsu] do
  include_examples 'opcode', :fmulsu

  it 'raises OpcodeNotImplementedError' do
    expect { cpu.instruction(:fmulsu, cpu.r16, cpu.r17).execute }.to raise_error(AVR::Opcode::OpcodeNotImplementedError)
  end
end
