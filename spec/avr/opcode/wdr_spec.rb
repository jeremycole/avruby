# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "wdr" do
    include_examples "opcode", :wdr

    it "does nothing" do
      cpu.instruction(:wdr).execute
    end
  end
end
