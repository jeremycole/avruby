require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :brbs] do
  include_examples "opcode", :brbs

  after(:each) do
    @cpu.sreg.reset
  end

  it "branches if the bit is set" do
    @cpu.sreg.Z = true
    @cpu.instruction(:brbs, :Z, +20).execute
    expect(@cpu.pc).to eq 21
  end

  it "does not branch if the bit is clear" do
    @cpu.sreg.Z = false
    @cpu.instruction(:brbs, :Z, +20).execute
    expect(@cpu.pc).to eq 1
  end
end
