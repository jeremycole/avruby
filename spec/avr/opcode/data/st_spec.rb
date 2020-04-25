require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :st] do
  include_examples "opcode", :st

  it "stores the register into the SRAM pointed to by X" do
    cpu.X = 0x0200
    cpu.r0 = 0xaf
    cpu.instruction(:st, cpu.X, cpu.r0).execute
    expect(cpu.sram.memory[0x0200].value).to eq 0xaf
    expect(cpu.X.value).to eq 0x0200
  end

  it "stores the register into the SRAM pointed to by -X" do
    cpu.X = 0x0200
    cpu.r0 = 0xaf
    cpu.instruction(:st, [cpu.X, :pre_decrement], cpu.r0).execute
    expect(cpu.sram.memory[0x01ff].value).to eq 0xaf
    expect(cpu.X.value).to eq 0x01ff
  end

  it "stores the register into the SRAM pointed to by X+" do
    cpu.X = 0x0200
    cpu.r0 = 0xaf
    cpu.instruction(:st, [cpu.X, :post_increment], cpu.r0).execute
    expect(cpu.sram.memory[0x0200].value).to eq 0xaf
    expect(cpu.X.value).to eq 0x0201
  end

  it "stores the register into the SRAM pointed to by Y" do
    cpu.Y = 0x0200
    cpu.r0 = 0xaf
    cpu.instruction(:st, [cpu.Y, :post_increment], cpu.r0).execute
    expect(cpu.sram.memory[0x0200].value).to eq 0xaf
    expect(cpu.Y.value).to eq 0x0201
  end

  it "stores the register into the SRAM pointed to by Z" do
    cpu.Z = 0x0200
    cpu.r0 = 0xaf
    cpu.instruction(:st, [cpu.Z, :post_increment], cpu.r0).execute
    expect(cpu.sram.memory[0x0200].value).to eq 0xaf
    expect(cpu.Z.value).to eq 0x0201
  end
end
