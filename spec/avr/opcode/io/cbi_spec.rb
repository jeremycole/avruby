# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "cbi" do
    let(:portb_io_address) { AVR::Value.new(cpu.PORTB.memory_byte.address - device.io_register_start) }
    let(:portb) { cpu.PORTB.memory_byte }

    include_examples "opcode", :cbi

    it "clears the bit in the IO register" do
      portb.value = 2
      cpu.instruction(:cbi, portb_io_address, AVR::Value.new(1)).execute
      expect(portb.value).to(eq(0))
    end

    it "does not change other bits in the IO register" do
      portb.value = 10
      cpu.instruction(:cbi, portb_io_address, AVR::Value.new(3)).execute
      expect(portb.value).to(eq(2))
    end

    it "does not do anything if the bit is already cleared" do
      portb.value = 2
      cpu.instruction(:cbi, portb_io_address, AVR::Value.new(3)).execute
      expect(portb.value).to(eq(2))
    end
  end
end
