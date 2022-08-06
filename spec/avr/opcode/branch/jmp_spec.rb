# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "jmp" do
    include_examples "opcode", :jmp

    it "sets PC to the specified constant" do
      cpu.instruction(:jmp, AVR::Value.new(0x0500)).execute
      expect(cpu.pc).to(eq(0x0500))
    end
  end
end
