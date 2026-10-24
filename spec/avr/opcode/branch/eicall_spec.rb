# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "eicall" do
    it_behaves_like "opcode", :eicall do
      it "pushes the current PC onto the stack" do
        previous_sp = cpu.sp.value
        cpu.pc.value = 0x1122
        cpu.Z = 0x1234
        cpu.instruction(:eicall).execute
        expect(cpu.sp.value).to(eq(previous_sp - 2))
        expect(cpu.data_address_space[cpu.sp.value + 1].value).to(eq(0x22 + 1))
        expect(cpu.data_address_space[cpu.sp.value + 2].value).to(eq(0x11))
      end

      it "sets PC to the specified constant in Z when EIND is not present" do
        cpu.Z = 0x1234
        cpu.instruction(:eicall).execute
        expect(cpu.pc).to(eq(0x1234))
      end

      context "when EIND register is present" do
        let(:device) do
          Class.new(AVR::Device::Atmel_ATmega328p) do
            def flash_size
              0x80000
            end
          end.new
        end

        it "sets PC to the address specified by EIND:Z" do
          eind_reg = AVR::MemoryByteRegister.new(cpu, "EIND", cpu.data_address_space[0x3c])
          cpu.io_registers.add(eind_reg)
          cpu.EIND.value = 0x02

          previous_sp = cpu.sp.value
          cpu.pc.value = 0x1122
          cpu.Z = 0x1234
          cpu.instruction(:eicall).execute
          expect(cpu.pc).to(eq(0x021234))
          expect(cpu.EIND.value).to(eq(0x02))
          expect(cpu.Z.value).to(eq(0x1234))
          expect(cpu.sp.value).to(eq(previous_sp - 2))
          expect(cpu.data_address_space[cpu.sp.value + 1].value).to(eq(0x22 + 1))
          expect(cpu.data_address_space[cpu.sp.value + 2].value).to(eq(0x11))
        end
      end
    end
  end
end
