# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "adiw" do
    let(:i) { cpu.instruction(:adiw, cpu.Z, AVR::Value.new(1)) }

    it_behaves_like "opcode", :adiw do
      it "adds correctly" do
        cpu.Z = 0
        i.execute
        expect(cpu.Z.value).to(eq(1))
      end

      it "does not set the carry flag without overflow" do
        cpu.Z = 0xfffe
        i.execute
        expect(cpu.sreg.C).to(be(0))
      end

      it "overflows to zero and sets the carry flag" do
        cpu.Z = 0xffff
        i.execute
        expect(cpu.Z.value).to(eq(0))
        expect(cpu.sreg.C).to(be(1))
      end

      it "does not add the carry flag" do
        cpu.Z = 0
        cpu.sreg.C = 1
        i.execute
        expect(cpu.Z.value).to(eq(1))
        expect(cpu.sreg.C).to(be(0))
      end
    end
  end
end
