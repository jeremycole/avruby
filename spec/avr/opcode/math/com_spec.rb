require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :com] do
  include_examples "opcode", :com

  before(:all) do
    @i = @cpu.instruction(:com, @cpu.r0)
  end

  it "performs ones complement correctly" do
    @cpu.r0 = 0xaa
    @i.execute
    expect(@cpu.r0.value).to eq 0x55
    @i.execute
    expect(@cpu.r0.value).to eq 0xaa
  end
end