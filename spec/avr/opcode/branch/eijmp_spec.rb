# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "eijmp" do
    include_examples "opcode", :eijmp

    it "is not implemented" do
      expect do
        cpu.instruction(:eijmp).execute
      end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
    end
  end
end
