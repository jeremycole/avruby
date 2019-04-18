require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :sleep] do
  include_examples "opcode", :sleep

  it "does nothing" do
    i = @cpu.instruction(:sleep)
    expect(i.execute).to be_nil
  end
end