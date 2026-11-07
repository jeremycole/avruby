# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "bclr" do
    it_behaves_like "opcode", :bclr do
      it "sets the correct SREG bit" do
        cpu.sreg.value = 0xff
        cpu.instruction(:bclr, AVR::RegisterWithNamedBit.new(cpu.sreg, :Z)).execute
        expect(cpu.sreg.I).to(be(1))
        expect(cpu.sreg.T).to(be(1))
        expect(cpu.sreg.H).to(be(1))
        expect(cpu.sreg.S).to(be(1))
        expect(cpu.sreg.V).to(be(1))
        expect(cpu.sreg.N).to(be(1))
        expect(cpu.sreg.Z).to(be(0))
        expect(cpu.sreg.C).to(be(1))
      end
    end
  end
end
