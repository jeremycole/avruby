# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "lpm" do
    include_examples "opcode", :lpm

    context "when called with no operands" do
      it "can execute" do
        cpu.instruction(:lpm).execute
      end
    end

    context "when called with a Z+ operand" do
      it "loads the program memory pointed to by Z into the register" do
        cpu.device.flash.memory[0x0500].value = 0xaf
        cpu.Z = 0x0500
        cpu.instruction(:lpm, cpu.r0, AVR::RegisterWithModification.new(cpu.Z, :post_increment)).execute
        expect(cpu.r0.value).to(eq(0xaf))
        expect(cpu.Z.value).to(eq(0x0501))
      end
    end
  end
end
