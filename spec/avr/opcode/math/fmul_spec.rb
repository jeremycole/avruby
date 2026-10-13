# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "fmul" do
    let(:i) { cpu.instruction(:fmul, cpu.r16, cpu.r17) }

    it_behaves_like "opcode", :fmul do
      it "performs fractional multiplication correctly" do
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

      it "sets the carry bit when the 17-bit result overflows 16 bits" do
        cpu.r16 = 255
        cpu.r17 = 255
        i.execute
        # (255 * 255) << 1 = 65025 << 1 = 130050 = 0x1fc02 => truncated to 0xfc02
        expect(cpu.r1r0.value).to(eq(0xfc02))
        expect(cpu.r1.value).to(eq(0xfc))
        expect(cpu.r0.value).to(eq(0x02))
        expect(cpu.sreg.C).to(be(true))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "handles boundary values without carry" do
        cpu.r16 = 128
        cpu.r17 = 128
        i.execute
        # (128 * 128) << 1 = 16384 << 1 = 32768 = 0x8000
        expect(cpu.r1r0.value).to(eq(0x8000))
        expect(cpu.r1.value).to(eq(0x80))
        expect(cpu.r0.value).to(eq(0x00))
        expect(cpu.sreg.C).to(be(false))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "handles maximum product below 16-bit overflow" do
        cpu.r16 = 128
        cpu.r17 = 255
        i.execute
        # (128 * 255) << 1 = 32640 << 1 = 65280 = 0xff00
        expect(cpu.r1r0.value).to(eq(0xff00))
        expect(cpu.r1.value).to(eq(0xff))
        expect(cpu.r0.value).to(eq(0x00))
        expect(cpu.sreg.C).to(be(false))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "sets carry when product just exceeds 16-bit range" do
        cpu.r16 = 129
        cpu.r17 = 255
        i.execute
        # (129 * 255) << 1 = 32895 << 1 = 65790 = 0x100fe => truncated to 0x00fe
        expect(cpu.r1r0.value).to(eq(0x00fe))
        expect(cpu.r1.value).to(eq(0x00))
        expect(cpu.r0.value).to(eq(0xfe))
        expect(cpu.sreg.C).to(be(true))
        expect(cpu.sreg.Z).to(be(false))
      end

      it "sets the Z bit when Rd is zero" do
        cpu.r16 = 0
        cpu.r17 = 123
        i.execute
        expect(cpu.r1r0.value).to(eq(0))
        expect(cpu.sreg.Z).to(be(true))
        expect(cpu.sreg.C).to(be(false))
      end

      it "sets the Z bit when Rr is zero" do
        cpu.r16 = 123
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
