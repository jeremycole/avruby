# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "ldi" do
    it_behaves_like "opcode", :ldi do
      it "loads the constant into the register" do
        cpu.r16 = 0
        cpu.instruction(:ldi, cpu.r16, AVR::Value.new(1)).execute
        expect(cpu.r16.value).to(eq(1))
      end

      it "validates that Rd is within r16..r31" do
        expect(cpu.instruction(:ldi, cpu.r16, AVR::Value.new(1)).valid?).to(be(true))
        expect { cpu.instruction(:ldi, cpu.r0, AVR::Value.new(1)).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:ldi, cpu.r15, AVR::Value.new(1)).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
      end
    end
  end
end
