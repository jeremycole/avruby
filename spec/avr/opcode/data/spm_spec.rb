# typed: false
require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "spm" do
    include_examples "opcode", :spm

    it "raises OpcodeNotImplementedError" do
      expect do
        cpu.instruction(:spm, AVR::RegisterWithModification.new(cpu.Z, :post_increment)).execute
      end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
    end
  end
end
