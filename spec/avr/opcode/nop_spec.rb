require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :nop] do
  include_examples "opcode", :nop

  it "does nothing" do
    i = @cpu.instruction(0, :nop)
    expect(i.execute).to be_nil
  end
end