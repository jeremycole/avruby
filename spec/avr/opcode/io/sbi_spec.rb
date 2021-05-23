# typed: false
require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "sbi" do
    let(:portb_io_address) { AVR::Value.new(cpu.PORTB.memory_byte.address - device.io_register_start) }
    let(:portb) { cpu.PORTB.memory_byte }

    include_examples "opcode", :sbi

    it "sets the bit in the IO register" do
      cpu.instruction(:sbi, portb_io_address, AVR::Value.new(1)).execute
      expect(portb.value).to(eq(2))
    end

    it "does not change other bits in the IO register" do
      portb.value = 2
      cpu.instruction(:sbi, portb_io_address, AVR::Value.new(3)).execute
      expect(portb.value).to(eq(10))
    end

    it "does not do anything if the bit is already set" do
      portb.value = 10
      cpu.instruction(:sbi, portb_io_address, AVR::Value.new(3)).execute
      expect(portb.value).to(eq(10))
    end
  end
end
