# typed: false
require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "break" do
    let(:i) do
      cpu.instruction(
        :movw,
        AVR::RegisterPair.new(cpu, cpu.r29, cpu.r28),
        AVR::RegisterPair.new(cpu, cpu.r31, cpu.r30)
      )
    end

    include_examples "opcode", :movw

    it "copies the source word register to the target word register" do
      cpu.Y = 0
      cpu.Z = 1
      i.execute
      expect(cpu.Y.value).to(eq(1))
      expect(cpu.Z.value).to(eq(1))
      cpu.Y = 1
      cpu.Z = 0
      i.execute
      expect(cpu.Y.value).to(eq(0))
      expect(cpu.Z.value).to(eq(0))
    end
  end
end
