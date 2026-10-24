# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::PC) do
  let(:flash_size_in_words) { 16_384 } # 32 KB flash = 16,384 words (0x4000)
  subject(:pc) { described_class.new(flash_size_in_words) }

  describe "initialization and defaults" do
    it "initializes with value 0 by default" do
      expect(pc.value).to(eq(0))
    end

    it "initializes with name '0' by default" do
      expect(pc.name).to(eq("0"))
    end

    it "exposes flash_size and calculated sizes" do
      expect(pc.size).to(eq(16_384))
      expect(pc.size_in_bytes).to(eq(32_768))
    end

    it "has format '%04x'" do
      expect(pc.format).to(eq("%04x"))
    end

    it "formats value_hex as 4 hex digits" do
      expect(pc.value_hex).to(eq("0000"))
      pc.value = 0x0100
      expect(pc.value_hex).to(eq("0100"))
    end
  end

  describe "value assignment" do
    it "sets values directly" do
      pc.value = 0x1234
      expect(pc.value).to(eq(0x1234))
    end
  end

  describe "#adjust, #increment, and #decrement" do
    it "adjusts by positive and negative offsets with wraparound" do
      pc.value = 0x3fff # 16,383 (last word in 32KB flash)
      expect(pc.adjust(1)).to(eq(0))
      expect(pc.value).to(eq(0))

      expect(pc.adjust(-1)).to(eq(0x3fff))
      expect(pc.value).to(eq(0x3fff))
    end

    it "increments by 1 by default and wraps around" do
      pc.value = 0x3fff
      expect(pc.increment).to(eq(0))
      expect(pc.value).to(eq(0))

      expect(pc.increment(5)).to(eq(5))
      expect(pc.value).to(eq(5))
    end

    it "decrements by 1 by default and wraps around" do
      pc.value = 0
      expect(pc.decrement).to(eq(0x3fff))
      expect(pc.value).to(eq(0x3fff))

      expect(pc.decrement(3)).to(eq(0x3ffc))
      expect(pc.value).to(eq(0x3ffc))
    end
  end

  describe "comparisons and conversions" do
    it "compares equal with another PC with same value" do
      other = described_class.new(flash_size_in_words)
      expect(pc).to(eq(other))
    end

    it "compares equal with an Integer with same value" do
      pc.value = 42
      expect(pc).to(eq(42))
      expect(pc == 42).to(be(true))
    end

    it "compares equal with an AVR::Value with same value" do
      val = AVR::Value.new(42)
      pc.value = 42
      expect(pc).to(eq(val))
    end

    it "returns false when compared to unrelated types" do
      expect(pc == "42").to(be(false))
    end

    it "converts to integer with to_i" do
      pc.value = 0x0123
      expect(pc.to_i).to(eq(0x0123))
    end

    it "inspects with class name and name" do
      expect(pc.inspect).to(eq("#<AVR::PC 0>"))
    end
  end

  describe "CPU integration" do
    let(:device) { AVR::Device::Atmel_ATmega328p.new }
    let(:cpu) { device.cpu }

    it "initializes cpu.pc and cpu.next_pc as AVR::PC instances" do
      expect(cpu.pc).to(be_a(described_class))
      expect(cpu.next_pc).to(be_a(described_class))
      expect(cpu.pc.size).to(eq(device.flash_size_in_words))
      expect(cpu.next_pc.size).to(eq(device.flash_size_in_words))
    end

    it "allows setting PC value via cpu.pc.value and cpu.next_pc.value" do
      cpu.pc.value = 0x0100
      expect(cpu.pc.value).to(eq(0x0100))

      cpu.next_pc.value = 0x0300
      expect(cpu.next_pc.value).to(eq(0x0300))
    end

    it "resets pc and next_pc to device.reset_address" do
      cpu.pc.value = 0x0500
      cpu.next_pc.value = 0x0501
      cpu.reset
      expect(cpu.pc.value).to(eq(device.reset_address))
      expect(cpu.next_pc.value).to(eq(device.reset_address))
    end
  end
end
