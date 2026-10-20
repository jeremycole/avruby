# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "fmuls" do
    let(:i) { cpu.instruction(:fmuls, cpu.r16, cpu.r17) }

    it_behaves_like "opcode", :fmuls do
      it "performs fractional multiplication of positive signed numbers" do
        cpu.r16 = 17
        cpu.r17 = 19
        i.execute
        # (17 * 19) << 1 = 323 << 1 = 646 = 0x0286
        expect(cpu.r1r0.value).to(eq(646))
        expect(cpu.r1.value).to(eq(0x02))
        expect(cpu.r0.value).to(eq(0x86))
        expect(cpu.sreg.C).to(be(false))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "performs fractional multiplication of positive and negative signed numbers" do
        cpu.r16 = 0xff # -1
        cpu.r17 = 1
        i.execute
        # (-1 * 1) = -1 => 0xffff << 1 = 0x1fffe => truncated to 0xfffe
        expect(cpu.r1r0.value).to(eq(0xfffe))
        expect(cpu.r1.value).to(eq(0xff))
        expect(cpu.r0.value).to(eq(0xfe))
        expect(cpu.sreg.C).to(be(true))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "performs fractional multiplication of two negative signed numbers" do
        cpu.r16 = 0xff # -1
        cpu.r17 = 0xff # -1
        i.execute
        # (-1 * -1) = 1 => 0x0001 << 1 = 0x0002
        expect(cpu.r1r0.value).to(eq(2))
        expect(cpu.r1.value).to(eq(0x00))
        expect(cpu.r0.value).to(eq(0x02))
        expect(cpu.sreg.C).to(be(false))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "handles maximum negative signed numbers" do
        cpu.r16 = 0x80 # -128
        cpu.r17 = 0x80 # -128
        i.execute
        # (-128 * -128) = 16384 => 0x4000 << 1 = 0x8000
        expect(cpu.r1r0.value).to(eq(0x8000))
        expect(cpu.r1.value).to(eq(0x80))
        expect(cpu.r0.value).to(eq(0x00))
        expect(cpu.sreg.C).to(be(false))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "handles maximum negative multiplicand with maximum positive multiplier" do
        cpu.r16 = 0x80 # -128
        cpu.r17 = 0x7f # 127
        i.execute
        # (-128 * 127) = -16256 => 0xc080 << 1 = 0x18100 => truncated to 0x8100
        expect(cpu.r1r0.value).to(eq(0x8100))
        expect(cpu.r1.value).to(eq(0x81))
        expect(cpu.r0.value).to(eq(0x00))
        expect(cpu.sreg.C).to(be(true))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "handles maximum positive signed numbers" do
        cpu.r16 = 0x7f # 127
        cpu.r17 = 0x7f # 127
        i.execute
        # (127 * 127) = 16129 => 0x3f01 << 1 = 0x7e02
        expect(cpu.r1r0.value).to(eq(0x7e02))
        expect(cpu.r1.value).to(eq(0x7e))
        expect(cpu.r0.value).to(eq(0x02))
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

      it "validates that Rd and Rr are within r16..r23" do
        expect(cpu.instruction(:fmuls, cpu.r16, cpu.r23).valid?).to(be(true))
        expect { cpu.instruction(:fmuls, cpu.r0, cpu.r16).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmuls, cpu.r15, cpu.r16).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmuls, cpu.r24, cpu.r16).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmuls, cpu.r31, cpu.r16).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmuls, cpu.r16, cpu.r0).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmuls, cpu.r16, cpu.r15).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmuls, cpu.r16, cpu.r24).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmuls, cpu.r16, cpu.r31).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
      end
    end
  end
end
