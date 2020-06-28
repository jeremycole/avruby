# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :rjmp] do
  include_examples 'opcode', :rjmp

  it 'adjusts PC by the specified offset' do
    cpu.instruction(:rjmp, AVR::Value.new(+20)).execute
    expect(cpu.pc).to eq 20 + 1
    cpu.instruction(:rjmp, AVR::Value.new(-10)).execute
    expect(cpu.pc).to eq 10 + 2
  end
end
