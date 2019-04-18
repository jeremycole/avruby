require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :las] do
  include_examples "opcode", :las

  it "exchanges the contents of the SRAM pointed to by Z with the register ORed with the register" do
    @cpu.Z = 0x0500
    @cpu.r0 = 0b00000110
    @cpu.sram.memory[0x0500].value = 0b11110000
    @cpu.instruction(:las, @cpu.r0).execute
    expect(@cpu.sram.memory[0x0500].value).to eq 0b11110110
    expect(@cpu.r0.value).to eq 0b11110000
  end
end