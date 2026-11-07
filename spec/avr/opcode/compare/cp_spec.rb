# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "cp" do
    let(:i) { cpu.instruction(:cp, cpu.r0, cpu.r1) }

    it_behaves_like "opcode", :cp do
      it "compares r0 == r1" do
        cpu.r0 = 5
        cpu.r1 = 5
        i.execute
        expect(cpu.sreg.Z).to(be(1))
        expect(cpu.sreg.C).to(be(0))
      end

      it "compares r0 < r1" do
        cpu.r0 = 5
        cpu.r1 = 6
        i.execute
        expect(cpu.sreg.Z).to(be(0))
        expect(cpu.sreg.C).to(be(1))
      end

      it "compares r0 > r1" do
        cpu.r0 = 6
        cpu.r1 = 5
        i.execute
        expect(cpu.sreg.Z).to(be(0))
        expect(cpu.sreg.C).to(be(0))
      end
    end
  end
end
