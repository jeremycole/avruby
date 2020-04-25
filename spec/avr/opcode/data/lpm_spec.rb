require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :lpm] do
  include_examples 'opcode', :lpm

  it 'loads the program memory pointed to by Z into the register' do
    cpu.device.flash.memory[0x0500].value = 0xaf
    cpu.Z = 0x0500
    cpu.instruction(:lpm, cpu.r0, [cpu.Z, :post_increment]).execute
    expect(cpu.r0.value).to eq 0xaf
    expect(cpu.Z.value).to eq 0x0501
  end
end
