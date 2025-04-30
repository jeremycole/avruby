# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "fmuls" do
    it_behaves_like "opcode", :fmuls do
      it "is not implemented" do
        expect do
          cpu.instruction(:fmuls, cpu.r16, cpu.r17).execute
        end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
      end
    end
  end
end
