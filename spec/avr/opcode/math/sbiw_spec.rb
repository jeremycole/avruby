# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "sbiw" do
    let(:i) { cpu.instruction(:sbiw, cpu.Z, AVR::Value.new(1)) }

    include_examples "opcode", :sbiw

    it "subtracts correctly" do
      cpu.Z = 1
      i.execute
      expect(cpu.Z.value).to(eq(0))
    end

    it "does not set the carry flag without overflow" do
      cpu.Z = 1
      i.execute
      expect(cpu.sreg.C).to(be(false))
    end

    it "overflows to 0xffff and sets the carry flag" do
      cpu.Z = 0
      i.execute
      expect(cpu.Z.value).to(eq(0xffff))
      expect(cpu.sreg.C).to(be(true))
    end

    it "does not subtract the carry flag" do
      cpu.Z = 2
      cpu.sreg.C = true
      i.execute
      expect(cpu.Z.value).to(eq(1))
      expect(cpu.sreg.C).to(be(false))
    end
  end
end
