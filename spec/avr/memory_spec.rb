# typed: false
# frozen_string_literal: true

require "tempfile"

RSpec.describe(AVR::Memory) do
  subject(:mem) { AVR::Memory::Flash.new(16) }

  it "has name and size" do
    expect(mem.name).to(eq("Flash"))
    expect(mem.size).to(eq(16))
  end

  it "inspects properly" do
    expect(mem.inspect).to(eq("#<AVR::Memory::Flash size=16>"))
  end

  describe "#set_word and #word" do
    it "writes and reads little-endian 16-bit words" do
      mem.set_word(0, 0x1234)
      expect(mem[0].value).to(eq(0x34))
      expect(mem[1].value).to(eq(0x12))
      expect(mem.word(0)).to(eq(0x1234))

      mem.set_word(1, 0xabcd)
      expect(mem[2].value).to(eq(0xcd))
      expect(mem[3].value).to(eq(0xab))
      expect(mem.word(1)).to(eq(0xabcd))
    end
  end

  describe "#load_from_intel_hex" do
    it "loads bytes from an Intel HEX file into memory" do
      temp = Tempfile.new(["test", ".hex"])
      # Intel Hex line: :040000001122334452
      # 4 bytes at address 0: 0x11, 0x22, 0x33, 0x44
      # End of file: :00000001FF
      temp.write(":040000001122334452\n:00000001FF\n")
      temp.flush

      count = mem.load_from_intel_hex(temp.path)
      temp.close
      temp.unlink

      expect(count).to(eq(4))
      expect(mem[0].value).to(eq(0x11))
      expect(mem[1].value).to(eq(0x22))
      expect(mem[2].value).to(eq(0x33))
      expect(mem[3].value).to(eq(0x44))
    end
  end
end
