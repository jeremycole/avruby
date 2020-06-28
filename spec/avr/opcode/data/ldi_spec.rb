# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :ldi] do
  include_examples 'opcode', :ldi

  it 'loads the constant into the register' do
    cpu.r0 = 0
    cpu.instruction(:ldi, cpu.r0, AVR::Value.new(1)).execute
    expect(cpu.r0.value).to eq 1
  end
end
