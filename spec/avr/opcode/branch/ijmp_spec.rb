require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :ijmp] do
  include_examples "opcode", :ijmp

  it "sets PC to the specified constant" do
    @cpu.Z = 0x0500
    @cpu.instruction(:ijmp).execute
    expect(@cpu.pc).to eq 0x0500
  end
end
