require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :in] do
  include_examples "opcode", :in

  before(:all) do
    @portb = @cpu.PORTB.memory_byte
    @portb_io_address = @cpu.PORTB.memory_byte.address - @device.io_register_start
  end

  it "reads the contents of the IO register into the register" do
    @portb.value = 1
    @cpu.instruction(0, :in, @cpu.r0, @portb_io_address).execute
    expect(@cpu.r0.value).to eq 1
  end
end