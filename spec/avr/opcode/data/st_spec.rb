require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :st] do
  include_examples "opcode", :st

  it "stores the register into the SRAM pointed to by X" do
    @cpu.X = 0x0200
    @cpu.r0 = 0xaf
    @cpu.instruction(:st, [@cpu.X, :post_increment], @cpu.r0).execute
    expect(@cpu.sram.memory[0x0200].value).to eq 0xaf
    expect(@cpu.X.value).to eq 0x0201
  end
end