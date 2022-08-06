# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "lac" do
    include_examples "opcode", :lac

    it "exchanges the contents of the SRAM pointed to by Z with the register AND NOTed with the register" do
      cpu.Z = 0x0500
      cpu.r0 = 0b01100000
      cpu.sram.memory[0x0500].value = 0b11110000
      cpu.instruction(:lac, cpu.r0).execute
      expect(cpu.sram.memory[0x0500].value).to(eq(0b10010000))
      expect(cpu.r0.value).to(eq(0b11110000))
    end
  end
end
