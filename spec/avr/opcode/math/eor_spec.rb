require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :eor] do
  include_examples 'opcode', :eor

  let(:i) { cpu.instruction(:eor, cpu.r0, cpu.r1) }

  it 'performs bitwise XOR correctly' do
    cpu.r0 = 0
    cpu.r1 = 0
    i.execute
    expect(cpu.r0.value).to eq 0
    expect(cpu.r1.value).to eq 0
    cpu.r0 = 0
    cpu.r1 = 1
    i.execute
    expect(cpu.r0.value).to eq 1
    expect(cpu.r1.value).to eq 1
    cpu.r0 = 1
    cpu.r1 = 0
    i.execute
    expect(cpu.r0.value).to eq 1
    expect(cpu.r1.value).to eq 0
    cpu.r0 = 1
    cpu.r1 = 1
    i.execute
    expect(cpu.r0.value).to eq 0
    expect(cpu.r1.value).to eq 1
    cpu.r0 = 0b01010101
    cpu.r1 = 0b01101100
    i.execute
    expect(cpu.r0.value).to eq 0b00111001
  end
end
