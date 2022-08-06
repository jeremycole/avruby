# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "push" do
    include_examples "opcode", :push

    it "pushes the register onto the stack" do
      cpu.r0 = 1
      previous_sp = cpu.sp.value
      cpu.instruction(:push, cpu.r0).execute

      expect(cpu.r0.value).to(eq(1))
      expect(cpu.sram.memory[cpu.sp.value + 1].value).to(eq(1))
      expect(cpu.sp.value).to(eq(previous_sp - 1))
    end
  end
end
