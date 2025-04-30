# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "jmp" do
    it_behaves_like "opcode", :jmp do
      it "sets PC to the specified constant" do
        cpu.instruction(:jmp, AVR::Value.new(0x0500)).execute
        expect(cpu.pc).to(eq(0x0500))
      end
    end
  end
end
