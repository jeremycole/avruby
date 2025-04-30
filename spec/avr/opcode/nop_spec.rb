# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "nop" do
    it_behaves_like "opcode", :nop do
      it "does nothing" do
        expect(cpu.instruction(:nop).execute).to(be_nil)
      end
    end
  end
end
