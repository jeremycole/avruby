# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "spm" do
    it_behaves_like "opcode", :spm do
      context "when called with no operands" do
        it "writes r1:r0 to the program memory pointed to by Z without incrementing Z" do
          cpu.r0 = 0x34
          cpu.r1 = 0x12
          cpu.Z = 0x0500
          cpu.instruction(:spm).execute
          expect(cpu.device.flash[0x0500].value).to(eq(0x34))
          expect(cpu.device.flash[0x0501].value).to(eq(0x12))
          expect(cpu.Z.value).to(eq(0x0500))
        end
      end

      context "when called with a Z operand" do
        it "writes r1:r0 to the program memory pointed to by Z without incrementing Z" do
          cpu.r0 = 0xcd
          cpu.r1 = 0xab
          cpu.Z = 0x0500
          cpu.instruction(:spm, AVR::RegisterWithModification.new(cpu.Z)).execute
          expect(cpu.device.flash[0x0500].value).to(eq(0xcd))
          expect(cpu.device.flash[0x0501].value).to(eq(0xab))
          expect(cpu.Z.value).to(eq(0x0500))
        end
      end

      context "when called with a Z+ operand" do
        it "writes r1:r0 to the program memory pointed to by Z and increments Z by 2" do
          cpu.r0 = 0x78
          cpu.r1 = 0x56
          cpu.Z = 0x0500
          cpu.instruction(:spm, AVR::RegisterWithModification.new(cpu.Z, :post_increment)).execute
          expect(cpu.device.flash[0x0500].value).to(eq(0x78))
          expect(cpu.device.flash[0x0501].value).to(eq(0x56))
          expect(cpu.Z.value).to(eq(0x0502))
        end
      end

      context "when RAMPZ register is present" do
        it "writes r1:r0 to the program memory addressed by RAMPZ:Z" do
          rampz_reg = AVR::MemoryByteRegister.new(cpu, "RAMPZ", cpu.data_address_space[0x3b])
          cpu.io_registers.add(rampz_reg)
          cpu.RAMPZ.value = 1

          large_flash = AVR::Memory::Flash.new(0x20000)
          allow(device).to receive(:flash).and_return(large_flash)

          cpu.r0 = 0xef
          cpu.r1 = 0xbe
          cpu.Z = 0x0500
          cpu.instruction(:spm, AVR::RegisterWithModification.new(cpu.Z, :post_increment)).execute
          expect(large_flash[0x10500].value).to(eq(0xef))
          expect(large_flash[0x10501].value).to(eq(0xbe))
          expect(cpu.Z.value).to(eq(0x0502))
          expect(cpu.RAMPZ.value).to(eq(1))
        end
      end
    end
  end
end
