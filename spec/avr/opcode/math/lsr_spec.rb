# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "lsr" do
    let(:i) { cpu.instruction(:lsr, cpu.r0) }

    include_examples "opcode", :lsr

    it "performs right-shift correctly" do
      cpu.r0 = 0b1010
      i.execute
      expect(cpu.r0.value).to(eq(0b101))
    end

    it "sets the carry bit when appropriate" do
      cpu.r0 = 0x01
      i.execute
      expect(cpu.r0.value).to(eq(0x00))
      expect(cpu.sreg.C).to(be(true))
    end

    it "sets the Z bit when the result is zero" do
      cpu.r0 = 0x01
      i.execute
      expect(cpu.sreg.Z).to(be(true))
    end
  end
end
