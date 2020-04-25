require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :cpse] do
  include_examples 'opcode', :cpse

  it 'compares r0 == r1, with 1-word instruction' do
    cpu.r0 = 5
    cpu.r1 = 5
    cpu.device.flash.set_word(0, 0b0001_0000_0000_0001) # cpse r0, r1
    cpu.device.flash.set_word(1, 0b0000_0000_0000_0000) # nop
    cpu.step
    expect(cpu.next_pc).to eq 2
  end

  it 'compares r0 == r1, with 2-word instruction' do
    cpu.r0 = 5
    cpu.r1 = 5
    cpu.device.flash.set_word(0, 0b0001_0000_0000_0001) # cpse r0, r1
    cpu.device.flash.set_word(1, 0b1001_0100_0000_1100) # jmp ...
    cpu.device.flash.set_word(2, 0b1010_1010_1010_1010) # ... 0xaaaa
    cpu.step
    expect(cpu.next_pc).to eq 3
  end

  it 'compares r0 != r1' do
    cpu.r0 = 3
    cpu.r1 = 5
    cpu.device.flash.set_word(0, 0b0001_0000_0000_0001) # cpse r0, r1
    cpu.device.flash.set_word(1, 0b0000_0000_0000_0000) # nop
    cpu.step
    expect(cpu.next_pc).to eq 1
  end
end
