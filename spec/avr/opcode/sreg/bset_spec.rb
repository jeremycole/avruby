# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "bset" do
    it_behaves_like "opcode", :bset do
      it "sets the correct SREG bit" do
        cpu.sreg.value = 0x00
        cpu.instruction(:bset, AVR::RegisterWithNamedBit.new(cpu.sreg, :Z)).execute
        expect(cpu.sreg.I).to(be(0))
        expect(cpu.sreg.T).to(be(0))
        expect(cpu.sreg.H).to(be(0))
        expect(cpu.sreg.S).to(be(0))
        expect(cpu.sreg.V).to(be(0))
        expect(cpu.sreg.N).to(be(0))
        expect(cpu.sreg.Z).to(be(1))
        expect(cpu.sreg.C).to(be(0))
      end
    end
  end
end
