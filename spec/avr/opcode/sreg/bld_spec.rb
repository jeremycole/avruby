# typed: false
require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "bld" do
    include_examples "opcode", :bld

    it "sets the bit in the register when the T flag is set" do
      cpu.r0 = 0b00000000
      cpu.sreg.T = true
      cpu.instruction(:bld, cpu.r0, AVR::Value.new(3)).execute
      expect(cpu.r0.value).to(eq(0b00001000))
      cpu.sreg.T = false # we're not supposed to have changed T
    end

    it "clears the bit in the register when the T flag is clear" do
      cpu.r0 = 0b00001000
      cpu.instruction(:bld, cpu.r0, AVR::Value.new(3)).execute
      expect(cpu.r0.value).to(eq(0b00000000))
    end
  end
end
