# typed: false
require "shared_examples_for_opcode"

RSpec.describe([AVR::Opcode, :lds]) do
  include_examples "opcode", :lds

  it "loads the data memory pointed to by an immediate into the register" do
    cpu.sram.memory[0x0500].value = 0xaf
    cpu.instruction(:lds, cpu.r0, AVR::Value.new(0x0500)).execute
    expect(cpu.r0.value).to(eq(0xaf))
  end
end
