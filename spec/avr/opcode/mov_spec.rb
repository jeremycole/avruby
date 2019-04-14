require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :mov] do
  include_examples "opcode", :mov

  before(:all) do
    @i = @cpu.instruction(0, :mov, @cpu.r0, @cpu.r1)
  end

  it "copies the source register to the target register" do
    @cpu.r0 = 0
    @cpu.r1 = 1
    @i.execute
    expect(@cpu.r0.value).to eq 1
    expect(@cpu.r1.value).to eq 1
    @cpu.r0 = 1
    @cpu.r1 = 0
    @i.execute
    expect(@cpu.r0.value).to eq 0
    expect(@cpu.r1.value).to eq 0
  end
end
