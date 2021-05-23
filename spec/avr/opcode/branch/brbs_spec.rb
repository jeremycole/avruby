# typed: false
require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "brbs" do
    include_examples "opcode", :brbs

    it "branches if the bit is set" do
      cpu.sreg.Z = true
      cpu.instruction(:brbs, AVR::Value.new(cpu.sreg.fetch_bit(:Z)), AVR::Value.new(+20)).execute
      expect(cpu.pc).to(eq(21))
      cpu.sreg.Z = false # we're not supposed to have changed Z
    end

    it "does not branch if the bit is clear" do
      cpu.instruction(:brbs, AVR::Value.new(cpu.sreg.fetch_bit(:Z)), AVR::Value.new(+20)).execute
      expect(cpu.pc).to(eq(1))
    end
  end
end
