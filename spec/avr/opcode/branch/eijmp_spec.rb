# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "eijmp" do
    it_behaves_like "opcode", :eijmp do
      it "sets PC to the specified constant in Z when EIND is not present" do
        cpu.Z = 0x0500
        cpu.instruction(:eijmp).execute
        expect(cpu.pc).to(eq(0x0500))
      end

      context "when EIND register is present" do
        it "sets PC to the address specified by EIND:Z" do
          eind_reg = AVR::MemoryByteRegister.new(cpu, "EIND", cpu.data_address_space[0x3c])
          cpu.io_registers.add(eind_reg)
          cpu.EIND.value = 0x02

          cpu.Z = 0x1234
          cpu.instruction(:eijmp).execute
          expect(cpu.pc).to(eq(0x021234))
          expect(cpu.EIND.value).to(eq(0x02))
          expect(cpu.Z.value).to(eq(0x1234))
        end
      end
    end
  end
end
