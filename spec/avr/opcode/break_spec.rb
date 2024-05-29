# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "break" do
    include_examples "opcode", :break

    it "does nothing" do
      expect(cpu.instruction(:break).execute).to(be_nil)
    end
  end
end
