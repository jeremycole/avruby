# typed: false
require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "eicall" do
    include_examples "opcode", :eicall

    it "is not implemented" do
      expect do
        cpu.instruction(:eicall).execute
      end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
    end
  end
end
