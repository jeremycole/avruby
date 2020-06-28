# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :ldd] do
  include_examples 'opcode', :ldd

  it 'loads the data in SRAM pointed to by Y + offset into the register' do
    cpu.Y = 0x0200
    cpu.sram.memory[0x0205].value = 0xaf
    cpu.instruction(:ldd, cpu.r0, AVR::RegisterWithDisplacement.new(cpu.Y, +5)).execute
    expect(cpu.r0.value).to eq 0xaf
    expect(cpu.Y.value).to eq 0x0200
  end

  it 'loads the data in SRAM pointed to by Z + offset into the register' do
    cpu.Z = 0x0200
    cpu.sram.memory[0x0205].value = 0xaf
    cpu.instruction(:ldd, cpu.r0, AVR::RegisterWithDisplacement.new(cpu.Z, +5)).execute
    expect(cpu.r0.value).to eq 0xaf
    expect(cpu.Z.value).to eq 0x0200
  end
end
