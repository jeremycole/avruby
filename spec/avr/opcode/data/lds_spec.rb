# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "lds" do
    it_behaves_like "opcode", :lds do
      it "loads the data memory pointed to by an immediate into the register" do
        cpu.sram[0x0500].value = 0xaf
        cpu.instruction(:lds, cpu.r16, AVR::Value.new(0x0500)).execute
        expect(cpu.r16.value).to(eq(0xaf))
      end

      it "validates that Rd is within r16..r31" do
        expect(cpu.instruction(:lds, cpu.r16, AVR::Value.new(0x0500)).valid?).to(be(true))
        expect { cpu.instruction(:lds, cpu.r0, AVR::Value.new(0x0500)).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:lds, cpu.r15, AVR::Value.new(0x0500)).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
      end
    end
  end
end
