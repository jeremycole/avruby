# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "spm" do
    include_examples "opcode", :spm

    context "when called with no operands" do
      it "is not implemented" do
        expect do
          cpu.instruction(:spm).execute
        end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
      end
    end

    context "when called with a Z operand" do
      it "is not implemented" do
        expect do
          cpu.instruction(:spm, AVR::RegisterWithModification.new(cpu.Z)).execute
        end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
      end
    end

    context "when called with a Z+ operand" do
      it "is not implemented" do
        expect do
          cpu.instruction(:spm, AVR::RegisterWithModification.new(cpu.Z, :post_increment)).execute
        end.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
      end
    end
  end
end
