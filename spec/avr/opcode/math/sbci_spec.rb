# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "sbci" do
    let(:i) { cpu.instruction(:sbci, cpu.r16, AVR::Value.new(1)) }

    it_behaves_like "opcode", :sbci do
      it "subtracts correctly" do
        cpu.r16 = 2
        i.execute
        expect(cpu.r16.value).to(eq(1))
      end

      it "does not set the carry flag without overflow" do
        cpu.r16 = 1
        i.execute
        expect(cpu.sreg.C).to(be(false))
      end

      it "overflows to zero and sets the carry flag" do
        cpu.r16 = 0
        i.execute
        expect(cpu.r16.value).to(eq(255))
        expect(cpu.sreg.C).to(be(true))
      end

      it "subtracts the carry flag" do
        cpu.r16 = 2
        cpu.sreg.C = true
        i.execute
        expect(cpu.r16.value).to(eq(0))
        expect(cpu.sreg.C).to(be(false))
      end

      it "validates that Rd is within r16..r31" do
        expect(cpu.instruction(:sbci, cpu.r16, AVR::Value.new(1)).valid?).to(be(true))
        expect { cpu.instruction(:sbci, cpu.r0, AVR::Value.new(1)).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:sbci, cpu.r15, AVR::Value.new(1)).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
      end
    end
  end
end
