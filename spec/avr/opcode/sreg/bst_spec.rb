# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "bst" do
    it_behaves_like "opcode", :bst do
      it "sets the T flag when the bit from the register is one" do
        cpu.sreg.T = 0
        cpu.r0 = 0b00001000
        cpu.instruction(:bst, cpu.r0, AVR::Value.new(3)).execute
        expect(cpu.sreg.T).to(be(1))
      end

      it "clears the T flag when the bit from the register is zero" do
        cpu.sreg.T = 1
        cpu.r0 = 0b00000000
        cpu.instruction(:bst, cpu.r0, AVR::Value.new(3)).execute
        expect(cpu.sreg.T).to(be(0))
      end
    end
  end
end
