# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::MemoryByte) do
  let(:memory) { AVR::Memory::MemoryByteBacked.new("Mem", 32) }
  subject(:byte) { memory[0x10] }

  before do
    byte.value = 0x41
  end

  it "exposes memory, address, and value" do
    expect(byte.memory).to(eq(memory))
    expect(byte.address).to(eq(0x10))
    expect(byte.value).to(eq(0x41))
  end

  it "formats as '%02x'" do
    expect(byte.format).to(eq("%02x"))
  end

  it "converts to integer with to_i" do
    expect(byte.to_i).to(eq(0x41))
  end

  it "converts to string with to_s" do
    expect(byte.to_s).to(eq("65"))
  end

  it "returns ASCII character with chr" do
    expect(byte.chr).to(eq("A"))
  end

  describe "#value=" do
    it "updates value and notifies memory on change" do
      allow(memory).to(receive(:notify).and_call_original)
      byte.value = 0x42
      expect(byte.value).to(eq(0x42))
      expect(memory).to(have_received(:notify).with(byte, 0x41, 0x42))
    end

    it "does not notify memory when set to the same value" do
      allow(memory).to(receive(:notify).and_call_original)
      byte.value = 0x41
      expect(memory).not_to(have_received(:notify))
    end

    it "raises error when value is below 0" do
      expect { byte.value = -1 }.to(raise_error(RuntimeError, "Value -1 out of range"))
    end

    it "raises error when value is above 255" do
      expect { byte.value = 256 }.to(raise_error(RuntimeError, "Value 256 out of range"))
    end
  end
end
