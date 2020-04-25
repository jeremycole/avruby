require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :break] do
  include_examples "opcode", :break

  it "does nothing" do
    i = cpu.instruction(:break)
    expect(i.execute).to be_nil
  end
end