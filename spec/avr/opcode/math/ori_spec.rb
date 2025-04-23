# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "ori" do
    it_behaves_like "opcode", :ori

    it "performs bitwise OR correctly" do
      cpu.r0 = 0b01010101
      cpu.instruction(:ori, cpu.r0, AVR::Value.new(0b01101100)).execute
      expect(cpu.r0.value).to(eq(0b01111101))
    end
  end
end
