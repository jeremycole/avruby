# typed: false
require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "muls" do
    include_examples "opcode", :muls

    it "is not implemented" do
      expect do
        cpu.instruction(:muls, cpu.r16, cpu.r17).execute
      end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
    end
  end
end
