# typed: false
require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "elpm" do
    include_examples "opcode", :elpm

    it "raises OpcodeNotImplementedError" do
      expect do
        cpu.instruction(:elpm, cpu.r0, AVR::RegisterWithModification.new(cpu.Z, :post_increment)).execute
      end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
    end
  end
end
