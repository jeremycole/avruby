# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :rcall] do
  include_examples 'opcode', :rcall

  it 'pushes the current PC onto the stack' do
    previous_sp = cpu.sp.value
    cpu.pc = 0x1122
    cpu.instruction(:rcall, AVR::Value.new(+20)).execute
    expect(cpu.sp.value).to eq previous_sp - 2
    expect(cpu.sram.memory[cpu.sp.value + 1].value).to eq 0x22 + 1
    expect(cpu.sram.memory[cpu.sp.value + 2].value).to eq 0x11
  end

  it 'adjusts PC by the specified offset' do
    cpu.instruction(:rcall, AVR::Value.new(+20)).execute
    expect(cpu.pc).to eq 20 + 1
    cpu.instruction(:rcall, AVR::Value.new(-10)).execute
    expect(cpu.pc).to eq 10 + 2
  end
end
