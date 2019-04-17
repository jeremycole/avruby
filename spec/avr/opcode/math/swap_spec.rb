require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :swap] do
  include_examples "opcode", :swap

  before(:all) do
    @i = @cpu.instruction(:swap, @cpu.r0)
  end

  it "performs nibble swap correctly" do
    @cpu.r0 = 0xf0
    @i.execute
    expect(@cpu.r0.value).to eq 0x0f
    @i.execute
    expect(@cpu.r0.value).to eq 0xf0
  end
end