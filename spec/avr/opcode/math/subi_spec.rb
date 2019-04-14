require 'shared_examples_for_opcode'

RSpec.describe AVR::Opcode, :subi do
  include_examples "opcode", :subi

  before(:all) do
    @i = @cpu.instruction(0, :subi, @cpu.r0, 1)
  end

  it "subtracts correctly" do
    @cpu.r0 = 2
    @i.execute
    expect(@cpu.r0.value).to be 1
  end

  it "does not set the carry flag without overflow" do
    @cpu.r0 = 1
    @i.execute
    expect(@cpu.sreg.C).to be false
  end

  it "overflows to zero and sets the carry flag" do
    @cpu.r0 = 0
    @i.execute
    expect(@cpu.r0.value).to be 255
    expect(@cpu.sreg.C).to be true
  end

  it "does not subtract the carry flag" do
    @cpu.r0 = 2
    @cpu.sreg.C = true
    @i.execute
    expect(@cpu.r0.value).to be 1
    expect(@cpu.sreg.C).to be false
  end
end