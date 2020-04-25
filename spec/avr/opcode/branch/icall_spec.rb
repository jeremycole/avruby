require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :icall] do
  include_examples "opcode", :icall

  it "pushes the current PC onto the stack" do
    previous_sp = cpu.sp.value
    cpu.pc = 0x1122
    cpu.Z = 0x1234
    cpu.instruction(:icall).execute
    expect(cpu.sp.value).to eq previous_sp - 2
    expect(cpu.sram.memory[cpu.sp.value+1].value).to eq 0x22 + 1
    expect(cpu.sram.memory[cpu.sp.value+2].value).to eq 0x11
  end

  it "sets PC to the specified constant" do
    cpu.Z = 0x1234
    cpu.instruction(:icall).execute
    expect(cpu.pc).to eq 0x1234
  end
end
