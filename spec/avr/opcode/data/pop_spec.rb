# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :push] do
  include_examples 'opcode', :push

  it 'pops the the stack into a register' do
    cpu.sram.memory[cpu.sp.value].value = 1
    cpu.sp.value -= 1
    previous_sp = cpu.sp.value
    cpu.instruction(:pop, cpu.r0).execute

    expect(cpu.r0.value).to eq 1
    expect(cpu.sp.value).to eq previous_sp + 1
  end
end
