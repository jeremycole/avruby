# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :muls] do
  include_examples 'opcode', :muls

  it 'raises OpcodeNotImplementedError' do
    expect { cpu.instruction(:muls, cpu.r16, cpu.r17).execute }.to raise_error(AVR::Opcode::OpcodeNotImplementedError)
  end
end
