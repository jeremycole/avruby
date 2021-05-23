# typed: false
require "shared_examples_for_opcode"

RSpec.describe([AVR::Opcode, :in]) do
  let(:portb_io_address) { AVR::Value.new(cpu.PORTB.memory_byte.address - device.io_register_start) }
  let(:portb) { cpu.PORTB.memory_byte }

  include_examples "opcode", :in

  it "reads the contents of the IO register into the register" do
    portb.value = 1
    cpu.instruction(:in, cpu.r0, portb_io_address).execute
    expect(cpu.r0.value).to(eq(1))
  end
end
