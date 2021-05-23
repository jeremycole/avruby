# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :fmuls] do
  include_examples 'opcode', :fmuls

  it 'raises OpcodeNotImplementedError' do
    expect { cpu.instruction(:fmuls, cpu.r16, cpu.r17).execute }.to raise_error(AVR::Opcode::OpcodeNotImplementedError)
  end
end
