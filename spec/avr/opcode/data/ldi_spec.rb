require 'shared_examples_for_opcode'

RSpec.describe AVR::Opcode, :ldi do
  include_examples "opcode", :ldi

  it "loads the constant into the register" do
    @cpu.r0 = 0
    @cpu.instruction(0, :ldi, @cpu.r0, 1).execute
    expect(@cpu.r0.value).to be 1
  end
end