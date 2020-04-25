require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :std] do
  include_examples 'opcode', :std

  it 'stores the register into the SRAM pointed to by Y + offset' do
    cpu.Y = 0x0200
    cpu.r0 = 0xaf
    cpu.instruction(:std, [cpu.Y, +5], cpu.r0).execute
    expect(cpu.sram.memory[0x0205].value).to eq 0xaf
    expect(cpu.Y.value).to eq 0x0200
  end

  it 'stores the register into the SRAM pointed to by Z + offset' do
    cpu.Z = 0x0200
    cpu.r0 = 0xaf
    cpu.instruction(:std, [cpu.Z, +5], cpu.r0).execute
    expect(cpu.sram.memory[0x0205].value).to eq 0xaf
    expect(cpu.Z.value).to eq 0x0200
  end
end
