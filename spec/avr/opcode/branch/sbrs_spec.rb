# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :sbrs] do
  include_examples 'opcode', :sbrs

  it 'skips if bit in r0 is set, with 1-word instruction' do
    cpu.r0 = 128
    cpu.device.flash.set_word(0, 0b1111_1110_0000_0111) # sbrs r0, 7
    cpu.device.flash.set_word(1, 0b0000_0000_0000_0000) # nop
    cpu.step
    expect(cpu.next_pc).to eq 2
  end

  it 'skips if bit in r0 is set, with 2-word instruction' do
    cpu.r0 = 128
    cpu.device.flash.set_word(0, 0b1111_1110_0000_0111) # sbrs r0, 7
    cpu.device.flash.set_word(1, 0b1001_0100_0000_1100) # jmp ...
    cpu.device.flash.set_word(2, 0b1010_1010_1010_1010) # ... 0xaaaa
    cpu.step
    expect(cpu.next_pc).to eq 3
  end

  it 'does not skip if bit in r0 is cleared, with 1-word instruction' do
    cpu.r0 = 5
    cpu.device.flash.set_word(0, 0b1111_1110_0000_0111) # sbrs r0, 7
    cpu.device.flash.set_word(1, 0b0000_0000_0000_0000) # nop
    cpu.step
    expect(cpu.next_pc).to eq 1
  end
end
