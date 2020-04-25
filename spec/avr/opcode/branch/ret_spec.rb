require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :ret] do
  include_examples 'opcode', :ret

  it 'sets PC to the value from the stack' do
    AVR::Opcode.stack_push_word(cpu, 0x0500)
    cpu.instruction(:ret).execute
    expect(cpu.pc).to eq 0x0500
  end
end
