# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "ori" do
    it_behaves_like "opcode", :ori do
      it "performs bitwise OR correctly" do
        cpu.r16 = 0b01010101
        cpu.instruction(:ori, cpu.r16, AVR::Value.new(0b01101100)).execute
        expect(cpu.r16.value).to(eq(0b01111101))
      end

      it "validates that Rd is within r16..r31" do
        expect(cpu.instruction(:ori, cpu.r16, AVR::Value.new(0)).valid?).to(be(true))
        expect { cpu.instruction(:ori, cpu.r0, AVR::Value.new(0)).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:ori, cpu.r15, AVR::Value.new(0)).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
      end
    end
  end
end
