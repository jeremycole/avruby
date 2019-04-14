require 'shared_examples_for_opcode'

RSpec.describe AVR::Opcode, :rjmp do
  include_examples "opcode", :rjmp

  it "adjusts PC by the specified offset" do
    @cpu.instruction(0, :rjmp, +20).execute
    expect(@cpu.pc).to eq 20 + 1
    @cpu.instruction(0, :rjmp, -10).execute
    expect(@cpu.pc).to eq 10 + 2
  end
end
