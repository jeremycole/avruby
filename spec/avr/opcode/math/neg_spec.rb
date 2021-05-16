# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :neg] do
  include_examples 'opcode', :neg

  let(:i) { cpu.instruction(:neg, cpu.r0) }

  it 'performs twos complement correctly' do
    cpu.r0 = 0b10101010
    i.execute
    expect(cpu.r0.value).to eq 0b01010110
    i.execute
    expect(cpu.r0.value).to eq 0b10101010
  end

  it 'does not set the carry bit when the result is zero' do
    cpu.r0 = 0x00
    i.execute
    expect(cpu.r0.value).to eq 0x00
    expect(cpu.sreg.C).to be_falsey
  end

  it 'sets the carry bit when the result is not zero' do
    cpu.r0 = 0x01
    i.execute
    expect(cpu.r0.value).to eq 0xff
    expect(cpu.sreg.C).to be_truthy
  end
end
