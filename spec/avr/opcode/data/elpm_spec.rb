# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "elpm" do
    it_behaves_like "opcode", :elpm do
      context "when called with no operands" do
        it "loads the program memory pointed to by Z into r0 without incrementing Z" do
          cpu.device.flash.memory[0x0500].value = 0xaf
          cpu.Z = 0x0500
          cpu.instruction(:elpm).execute
          expect(cpu.r0.value).to(eq(0xaf))
          expect(cpu.Z.value).to(eq(0x0500))
        end
      end

      context "when called with Rd and Z operand" do
        it "loads the program memory pointed to by Z into Rd without incrementing Z" do
          cpu.device.flash.memory[0x0500].value = 0xbc
          cpu.Z = 0x0500
          cpu.instruction(:elpm, cpu.r16, AVR::RegisterWithModification.new(cpu.Z)).execute
          expect(cpu.r16.value).to(eq(0xbc))
          expect(cpu.Z.value).to(eq(0x0500))
        end
      end

      context "when called with Rd and Z+ operand" do
        it "loads the program memory pointed to by Z into Rd and increments Z" do
          cpu.device.flash.memory[0x0500].value = 0xde
          cpu.Z = 0x0500
          cpu.instruction(:elpm, cpu.r16, AVR::RegisterWithModification.new(cpu.Z, :post_increment)).execute
          expect(cpu.r16.value).to(eq(0xde))
          expect(cpu.Z.value).to(eq(0x0501))
        end
      end

      context "when RAMPZ register is present" do
        it "loads the program memory addressed by RAMPZ:Z" do
          rampz_reg = AVR::MemoryByteRegister.new(cpu, "RAMPZ", cpu.sram.memory[0x3b])
          cpu.io_registers.add(rampz_reg)
          cpu.RAMPZ.value = 1

          large_flash = AVR::Flash.new(0x20000)
          large_flash.memory[0x10500].value = 0x42
          allow(device).to receive(:flash).and_return(large_flash)

          cpu.Z = 0x0500
          cpu.instruction(:elpm, cpu.r18, AVR::RegisterWithModification.new(cpu.Z, :post_increment)).execute
          expect(cpu.r18.value).to(eq(0x42))
          expect(cpu.Z.value).to(eq(0x0501))
          expect(cpu.RAMPZ.value).to(eq(1))
        end
      end
    end
  end
end
