# typed: false
require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "xch" do
    include_examples "opcode", :xch

    it "exchanges the contents of the SRAM pointed to by Z with the register" do
      cpu.Z = 0x0500
      cpu.r0 = 0x55
      cpu.sram.memory[0x0500].value = 0xaa
      cpu.instruction(:xch, cpu.r0).execute
      expect(cpu.sram.memory[0x0500].value).to(eq(0x55))
      expect(cpu.r0.value).to(eq(0xaa))
    end
  end
end
