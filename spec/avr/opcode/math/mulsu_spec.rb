# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "mulsu" do
    it_behaves_like "opcode", :mulsu do
      it "is not implemented" do
        expect do
          cpu.instruction(:mulsu, cpu.r16, cpu.r17).execute
        end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
      end
    end
  end
end
