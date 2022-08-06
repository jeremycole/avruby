# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "brbc" do
    include_examples "opcode", :brbc

    it "branches if the bit is set" do
      cpu.sreg.Z = true
      cpu.instruction(:brbc, AVR::Value.new(cpu.sreg.fetch_bit(:Z)), AVR::Value.new(+20)).execute
      expect(cpu.pc).to(eq(1))
      cpu.sreg.Z = false # we're not supposed to have changed Z
    end

    it "does not branch if the bit is clear" do
      cpu.instruction(:brbc, AVR::Value.new(cpu.sreg.fetch_bit(:Z)), AVR::Value.new(+20)).execute
      expect(cpu.pc).to(eq(21))
    end
  end
end
