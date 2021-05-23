# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :fmul] do
  include_examples 'opcode', :fmul

  it 'raises OpcodeNotImplementedError' do
    expect { cpu.instruction(:fmul, cpu.r16, cpu.r17).execute }.to raise_error(AVR::Opcode::OpcodeNotImplementedError)
  end
end
