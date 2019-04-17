require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :out] do
  include_examples "opcode", :out

  before(:all) do
    @portb = @cpu.PORTB.memory_byte
    @portb_io_address = @cpu.PORTB.memory_byte.address - @device.io_register_start
  end

  it "writes the contents of the register into the IO register" do
    @cpu.r0.value = 1
    @cpu.instruction(:out, @portb_io_address, @cpu.r0).execute
    expect(@portb.value).to eq 1
  end
end