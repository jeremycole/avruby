# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :sts] do
  include_examples 'opcode', :sts

  it 'stores the contents of the register into data memory pointed to by an immediate' do
    cpu.r0 = 0xaf
    cpu.instruction(:sts, AVR::Value.new(0x0500), cpu.r0).execute
    expect(cpu.sram.memory[0x0500].value).to eq 0xaf
  end
end
