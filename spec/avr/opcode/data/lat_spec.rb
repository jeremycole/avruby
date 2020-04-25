require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :lat] do
  include_examples "opcode", :lat

  it "exchanges the contents of the SRAM pointed to by Z with the register XORed with the register" do
    cpu.Z = 0x0500
    cpu.r0 = 0b01100110
    cpu.sram.memory[0x0500].value = 0b11110000
    cpu.instruction(:lat, cpu.r0).execute
    expect(cpu.sram.memory[0x0500].value).to eq 0b10010110
    expect(cpu.r0.value).to eq 0b11110000
  end
end