# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :ld] do
  include_examples 'opcode', :ld

  it 'loads the data in SRAM pointed to by X into the register' do
    cpu.X = 0x0200
    cpu.sram.memory[0x0200].value = 0xaf
    cpu.instruction(:ld, cpu.r0, AVR::RegisterWithModification.new(cpu.X)).execute
    expect(cpu.r0.value).to eq 0xaf
    expect(cpu.X.value).to eq 0x0200
  end

  it 'loads the data in SRAM pointed to by -X into the register' do
    cpu.X = 0x0200
    cpu.sram.memory[0x01ff].value = 0xaf
    cpu.instruction(:ld, cpu.r0, AVR::RegisterWithModification.new(cpu.X, :pre_decrement)).execute
    expect(cpu.r0.value).to eq 0xaf
    expect(cpu.X.value).to eq 0x01ff
  end

  it 'loads the data in SRAM pointed to by X+ into the register' do
    cpu.X = 0x0200
    cpu.sram.memory[0x0200].value = 0xaf
    cpu.instruction(:ld, cpu.r0, AVR::RegisterWithModification.new(cpu.X, :post_increment)).execute
    expect(cpu.r0.value).to eq 0xaf
    expect(cpu.X.value).to eq 0x0201
  end

  it 'loads the data in SRAM pointed to by Y+ into the register' do
    cpu.Y = 0x0200
    cpu.sram.memory[0x0200].value = 0xaf
    cpu.instruction(:ld, cpu.r0, AVR::RegisterWithModification.new(cpu.Y, :post_increment)).execute
    expect(cpu.r0.value).to eq 0xaf
    expect(cpu.Y.value).to eq 0x0201
  end

  it 'loads the data in SRAM pointed to by Z+ into the register' do
    cpu.Z = 0x0200
    cpu.sram.memory[0x0200].value = 0xaf
    cpu.instruction(:ld, cpu.r0, AVR::RegisterWithModification.new(cpu.Z, :post_increment)).execute
    expect(cpu.r0.value).to eq 0xaf
    expect(cpu.Z.value).to eq 0x0201
  end
end
