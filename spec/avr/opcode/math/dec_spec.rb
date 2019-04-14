require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :dec] do
  include_examples "opcode", :dec

  before(:all) do
    @i = @cpu.instruction(0, :dec, @cpu.r0)
  end

  it "decrements correctly" do
    @cpu.r0 = 1
    @i.execute
    expect(@cpu.r0.value).to eq 0
  end

  it "underflows to 255 and does not set the carry flag" do
    @cpu.r0 = 0
    @i.execute
    expect(@cpu.r0.value).to eq 255
    expect(@cpu.sreg.C).to be false
  end
end