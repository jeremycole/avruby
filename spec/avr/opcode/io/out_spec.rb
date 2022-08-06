# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "out" do
    let(:portb_io_address) { AVR::Value.new(cpu.PORTB.memory_byte.address - device.io_register_start) }
    let(:portb) { cpu.PORTB.memory_byte }

    include_examples "opcode", :out

    it "writes the contents of the register into the IO register" do
      cpu.r0.value = 1
      cpu.instruction(:out, portb_io_address, cpu.r0).execute
      expect(portb.value).to(eq(1))
    end
  end
end
