require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :reti] do
  include_examples "opcode", :reti

  it "sets PC to the value from the stack" do
    AVR::Opcode.stack_push_word(@cpu, 0x0500)
    @cpu.instruction(:reti).execute
    expect(@cpu.pc).to eq 0x0500
    expect(@cpu.sreg.I).to be true
  end
end
