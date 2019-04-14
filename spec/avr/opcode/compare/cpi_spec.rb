require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :cpi] do
  include_examples "opcode", :cpi

  before(:all) do
    @i = @cpu.instruction(0, :cpi, @cpu.r0, 5)
  end

  it "compares r0 == K" do
    @cpu.r0 = 5
    @i.execute
    expect(@cpu.sreg.Z).to be true
    expect(@cpu.sreg.C).to be false
  end

  it "compares r0 < K" do
    @cpu.r0 = 4
    @i.execute
    expect(@cpu.sreg.Z).to be false
    expect(@cpu.sreg.C).to be true
  end

  it "compares r0 > K" do
    @cpu.r0 = 6
    @i.execute
    expect(@cpu.sreg.Z).to be false
    expect(@cpu.sreg.C).to be false
  end
end
