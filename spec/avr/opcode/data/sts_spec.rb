# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "sts" do
    it_behaves_like "opcode", :sts do
      it "stores the contents of the register into data memory pointed to by an immediate" do
        cpu.r16 = 0xaf
        cpu.instruction(:sts, AVR::Value.new(0x0500), cpu.r16).execute
        expect(cpu.data_address_space[0x0500].value).to(eq(0xaf))
      end

      it "validates that Rr is within r16..r31" do
        expect(cpu.instruction(:sts, AVR::Value.new(0x0500), cpu.r16).valid?).to(be(true))
        expect { cpu.instruction(:sts, AVR::Value.new(0x0500), cpu.r0).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:sts, AVR::Value.new(0x0500), cpu.r15).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
      end
    end
  end
end
