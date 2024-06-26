# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "sleep" do
    include_examples "opcode", :sleep

    it "does nothing" do
      expect(cpu.instruction(:sleep).execute).to(be_nil)
    end
  end
end
