# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "cpc" do
    let(:i) { cpu.instruction(:cpc, cpu.r0, cpu.r1) }

    it_behaves_like "opcode", :cpc do
      it "compares r0 == r1, Z=1, C=0" do
        cpu.r0 = 5
        cpu.r1 = 5
        cpu.sreg.Z = 1
        cpu.sreg.C = 0
        i.execute
        expect(cpu.sreg.Z).to(be(1))
        expect(cpu.sreg.C).to(be(0))
      end

      it "compares r0 < r1, Z=0, C=0" do
        cpu.r0 = 5
        cpu.r1 = 6
        cpu.sreg.Z = 0
        cpu.sreg.C = 0
        i.execute
        expect(cpu.sreg.Z).to(be(0))
        expect(cpu.sreg.C).to(be(1))
      end

      it "compares r0 > r1, Z=0, C=0" do
        cpu.r0 = 6
        cpu.r1 = 5
        cpu.sreg.Z = 0
        cpu.sreg.C = 0
        i.execute
        expect(cpu.sreg.Z).to(be(0))
        expect(cpu.sreg.C).to(be(0))
      end
    end
  end
end
