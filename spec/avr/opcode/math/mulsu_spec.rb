# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "mulsu" do
    let(:i) { cpu.instruction(:mulsu, cpu.r16, cpu.r17) }

    it_behaves_like "opcode", :mulsu do
      it "performs multiplication of positive signed and unsigned numbers" do
        cpu.r16 = 17
        cpu.r17 = 19
        i.execute
        expect(cpu.r1r0.value).to(eq(17 * 19))
        expect(cpu.sreg.C).to(be(false))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "performs multiplication of negative signed and unsigned numbers" do
        cpu.r16 = 0xff # -1
        cpu.r17 = 1
        i.execute
        expect(cpu.r1r0.value).to(eq(0xffff))
        expect(cpu.sreg.C).to(be(true))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "handles maximum negative signed multiplicand with unsigned multiplier" do
        cpu.r16 = 0x80 # -128
        cpu.r17 = 255  # 255
        i.execute
        # -128 * 255 = -32640 => 0x8080 (32896 in unsigned 16-bit)
        expect(cpu.r1r0.value).to(eq(0x8080))
        expect(cpu.r1.value).to(eq(0x80))
        expect(cpu.r0.value).to(eq(0x80))
        expect(cpu.sreg.C).to(be(true))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "handles maximum positive signed multiplicand with maximum unsigned multiplier" do
        cpu.r16 = 0x7f # 127
        cpu.r17 = 255  # 255
        i.execute
        # 127 * 255 = 32385 => 0x7e81
        expect(cpu.r1r0.value).to(eq(0x7e81))
        expect(cpu.r1.value).to(eq(0x7e))
        expect(cpu.r0.value).to(eq(0x81))
        expect(cpu.sreg.C).to(be(false))
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

      it "validates that Rd and Rr are within r16..r23" do
        expect(cpu.instruction(:mulsu, cpu.r16, cpu.r23).valid?).to(be(true))
        expect { cpu.instruction(:mulsu, cpu.r0, cpu.r16).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:mulsu, cpu.r15, cpu.r16).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:mulsu, cpu.r24, cpu.r16).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:mulsu, cpu.r31, cpu.r16).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:mulsu, cpu.r16, cpu.r0).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:mulsu, cpu.r16, cpu.r15).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:mulsu, cpu.r16, cpu.r24).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
        expect { cpu.instruction(:mulsu, cpu.r16, cpu.r31).execute }.to(raise_error(AVR::Opcode::RegisterOutOfRange))
      end
    end
  end
end
