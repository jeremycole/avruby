# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "elpm" do
    it_behaves_like "opcode", :elpm

    it "is not implemented" do
      expect do
        cpu.instruction(:elpm, cpu.r0, AVR::RegisterWithModification.new(cpu.Z, :post_increment)).execute
      end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
    end
  end
end
