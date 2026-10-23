# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "brbs" do
    it_behaves_like "opcode", :brbs do

      [:C, :Z, :N, :V, :S, :H, :T, :I].each_with_index do |bit, i|
        it "branches if the bit (#{bit}, #{i}) is set" do
          cpu.sreg.value = 1 << i
          cpu.instruction(:brbs, AVR::Value.new(i), AVR::Value.new(+20)).execute
          expect(cpu.pc).to(eq(21))
          cpu.sreg.value = 0 # we're not supposed to have changed SREG
        end

        it "does not branch if the bit (#{bit}, #{i}) is clear" do
          cpu.instruction(:brbs, AVR::Value.new(i), AVR::Value.new(+20)).execute
          expect(cpu.pc).to(eq(1))
        end
      end
    end
  end
end
