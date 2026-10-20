# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "cpi" do
    let(:i) { cpu.instruction(:cpi, cpu.r16, AVR::Value.new(5)) }

    it_behaves_like "opcode", :cpi do
      it "compares r16 == K" do
        cpu.r16 = 5
        i.execute
        expect(cpu.sreg.Z).to(be(true))
        expect(cpu.sreg.C).to(be(false))
      end

      it "compares r16 < K" do
        cpu.r16 = 4
        i.execute
        expect(cpu.sreg.Z).to(be(false))
        expect(cpu.sreg.C).to(be(true))
      end

      it "compares r16 > K" do
        cpu.r16 = 6
        i.execute
        expect(cpu.sreg.Z).to(be(false))
        expect(cpu.sreg.C).to(be(false))
      end

      it "validates that Rd is within r16..r31" do
        expect(cpu.instruction(:cpi, cpu.r16, AVR::Value.new(5)).valid?).to(be(true))
        expect { cpu.instruction(:cpi, cpu.r0, AVR::Value.new(5)).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:cpi, cpu.r15, AVR::Value.new(5)).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
      end
    end
  end
end
