# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "muls" do
    let(:i) { cpu.instruction(:muls, cpu.r16, cpu.r17) }

    it_behaves_like "opcode", :muls do
      it "performs multiplication of positive signed numbers" do
        cpu.r16 = 17
        cpu.r17 = 19
        i.execute
        expect(cpu.r1r0.value).to(eq(17 * 19))
        expect(cpu.sreg.C).to(be(false))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "performs multiplication of positive and negative signed numbers" do
        cpu.r16 = 0xff # -1
        cpu.r17 = 1
        i.execute
        expect(cpu.r1r0.value).to(eq(0xffff))
        expect(cpu.sreg.C).to(be(true))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "performs multiplication of two negative signed numbers" do
        cpu.r16 = 0xff # -1
        cpu.r17 = 0xff # -1
        i.execute
        expect(cpu.r1r0.value).to(eq(1))
        expect(cpu.r1.value).to(eq(0))
        expect(cpu.r0.value).to(eq(1))
        expect(cpu.sreg.C).to(be(false))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "handles maximum negative signed numbers" do
        cpu.r16 = 0x80 # -128
        cpu.r17 = 0x80 # -128
        i.execute
        # -128 * -128 = 16384 => 0x4000
        expect(cpu.r1r0.value).to(eq(0x4000))
        expect(cpu.r1.value).to(eq(0x40))
        expect(cpu.r0.value).to(eq(0x00))
        expect(cpu.sreg.C).to(be(false))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "handles maximum negative signed multiplicand with maximum positive multiplier" do
        cpu.r16 = 0x80 # -128
        cpu.r17 = 0x7f # 127
        i.execute
        # -128 * 127 = -16256 => 0xc080
        expect(cpu.r1r0.value).to(eq(0xc080))
        expect(cpu.r1.value).to(eq(0xc0))
        expect(cpu.r0.value).to(eq(0x80))
        expect(cpu.sreg.C).to(be(true))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "handles maximum positive signed numbers" do
        cpu.r16 = 0x7f # 127
        cpu.r17 = 0x7f # 127
        i.execute
        # 127 * 127 = 16129 => 0x3f01
        expect(cpu.r1r0.value).to(eq(0x3f01))
        expect(cpu.r1.value).to(eq(0x3f))
        expect(cpu.r0.value).to(eq(0x01))
        expect(cpu.sreg.C).to(be(false))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "sets the Z bit when Rd is zero" do
        cpu.r16 = 0
        cpu.r17 = 0xfe # -2
        i.execute
        expect(cpu.r1r0.value).to(eq(0))
        expect(cpu.sreg.Z).to(be(true))
        expect(cpu.sreg.C).to(be(false))
      end

      it "sets the Z bit when Rr is zero" do
        cpu.r16 = 0xfe # -2
        cpu.r17 = 0
        i.execute
        expect(cpu.r1r0.value).to(eq(0))
        expect(cpu.sreg.Z).to(be(true))
        expect(cpu.sreg.C).to(be(false))
      end

      it "sets the Z bit when both operands are zero" do
        cpu.r16 = 0
        cpu.r17 = 0
        i.execute
        expect(cpu.r1r0.value).to(eq(0))
        expect(cpu.sreg.Z).to(be(true))
        expect(cpu.sreg.C).to(be(false))
      end
    end
  end
end
