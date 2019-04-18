require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :wdr] do
  include_examples "opcode", :wdr

  it "does nothing" do
    i = @cpu.instruction(:wdr)
    expect(i.execute).to be_nil
  end
end