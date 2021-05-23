# typed: false
require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "eicall" do
    include_examples "opcode", :eicall

    it "raises OpcodeNotImplementedError" do
      expect { cpu.instruction(:eicall).execute }.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
    end
  end
end
