# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "and" do
    let(:i) { cpu.instruction(:and, cpu.r0, cpu.r1) }

    include_examples "opcode", :and

    it "performs bitwise AND correctly" do
      cpu.r0 = 0
      cpu.r1 = 1
      i.execute
      expect(cpu.r0.value).to(eq(0))
      expect(cpu.r1.value).to(eq(1))
      cpu.r0 = 1
      cpu.r1 = 1
      i.execute
      expect(cpu.r0.value).to(eq(1))
      expect(cpu.r1.value).to(eq(1))
      cpu.r0 = 0b01010101
      cpu.r1 = 0b01101100
      i.execute
      expect(cpu.r0.value).to(eq(0b01000100))
    end
  end
end
