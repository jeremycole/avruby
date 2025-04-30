# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "ijmp" do
    it_behaves_like "opcode", :ijmp do
      it "sets PC to the specified constant" do
        cpu.Z = 0x0500
        cpu.instruction(:ijmp).execute
        expect(cpu.pc).to(eq(0x0500))
      end
    end
  end
end
