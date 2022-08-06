# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "fmulsu" do
    include_examples "opcode", :fmulsu

    it "is not implemented" do
      expect do
        cpu.instruction(:fmulsu, cpu.r16, cpu.r17).execute
      end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
    end
  end
end
