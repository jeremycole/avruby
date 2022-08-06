# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "des" do
    include_examples "opcode", :des

    it "is not implemented" do
      expect do
        cpu.instruction(:des, AVR::Value.new(0)).execute
      end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
    end
  end
end
