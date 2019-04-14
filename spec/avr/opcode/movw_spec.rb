require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :movw] do
  include_examples "opcode", :movw

  before(:all) do
    @i = @cpu.instruction(0, :movw, @cpu.Y, @cpu.Z)
  end

  it "copies the source word register to the target word register" do
    @cpu.Y = 0
    @cpu.Z = 1
    @i.execute
    expect(@cpu.Y.value).to eq 1
    expect(@cpu.Z.value).to eq 1
    @cpu.Y = 1
    @cpu.Z = 0
    @i.execute
    expect(@cpu.Y.value).to eq 0
    expect(@cpu.Z.value).to eq 0
  end
end
