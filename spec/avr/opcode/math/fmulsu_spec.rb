# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "fmulsu" do
    let(:i) { cpu.instruction(:fmulsu, cpu.r16, cpu.r17) }

    it_behaves_like "opcode", :fmulsu do
      it "performs fractional multiplication of positive signed and unsigned numbers" do
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

      it "performs fractional multiplication of negative signed and unsigned numbers" do
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

      it "handles maximum negative signed multiplicand with maximum unsigned multiplier" do
        cpu.r16 = 0x80 # -128
        cpu.r17 = 255  # 255
        i.execute
        # (-128 * 255) = -32640 => 0x8080 << 1 = 0x10100 => truncated to 0x0100
        expect(cpu.r1r0.value).to(eq(0x0100))
        expect(cpu.r1.value).to(eq(0x01))
        expect(cpu.r0.value).to(eq(0x00))
        expect(cpu.sreg.C).to(be(true))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "handles maximum positive signed multiplicand with maximum unsigned multiplier" do
        cpu.r16 = 0x7f # 127
        cpu.r17 = 255  # 255
        i.execute
        # (127 * 255) = 32385 => 0x7e81 << 1 = 0xfd02
        expect(cpu.r1r0.value).to(eq(0xfd02))
        expect(cpu.r1.value).to(eq(0xfd))
        expect(cpu.r0.value).to(eq(0x02))
        expect(cpu.sreg.C).to(be(false))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "handles negative signed multiplicand with power-of-two unsigned multiplier" do
        cpu.r16 = 0x80 # -128
        cpu.r17 = 128  # 128
        i.execute
        # (-128 * 128) = -16384 => 0xc000 << 1 = 0x18000 => truncated to 0x8000
        expect(cpu.r1r0.value).to(eq(0x8000))
        expect(cpu.r1.value).to(eq(0x80))
        expect(cpu.r0.value).to(eq(0x00))
        expect(cpu.sreg.C).to(be(true))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "sets the Z bit when the signed multiplicand is zero" do
        cpu.r16 = 0
        cpu.r17 = 123
        i.execute
        expect(cpu.r1r0.value).to(eq(0))
        expect(cpu.sreg.Z).to(be(true))
        expect(cpu.sreg.C).to(be(false))
      end

      it "sets the Z bit when the unsigned multiplier is zero" do
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
        expect(cpu.instruction(:fmulsu, cpu.r16, cpu.r23).valid?).to(be(true))
        expect { cpu.instruction(:fmulsu, cpu.r0, cpu.r16).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmulsu, cpu.r15, cpu.r16).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmulsu, cpu.r24, cpu.r16).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmulsu, cpu.r31, cpu.r16).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmulsu, cpu.r16, cpu.r0).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmulsu, cpu.r16, cpu.r15).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmulsu, cpu.r16, cpu.r24).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:fmulsu, cpu.r16, cpu.r31).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
      end
    end
  end
end
