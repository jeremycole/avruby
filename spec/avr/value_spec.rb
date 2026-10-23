# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Value) do
  describe "defaults" do
    subject(:val) { described_class.new }

    it "initializes with value 0" do
      expect(val.value).to(eq(0))
    end

    it "initializes with name '0'" do
      expect(val.name).to(eq("0"))
    end

    it "has default format '%02x'" do
      expect(val.format).to(eq("%02x"))
    end

    it "formats value_hex as two hex digits" do
      expect(val.value_hex).to(eq("00"))
    end

    it "converts to integer with to_i" do
      expect(val.to_i).to(eq(0))
    end

    it "converts to string with to_s" do
      expect(val.to_s).to(eq("0"))
    end

    it "inspects as #<AVR::Value 0>" do
      expect(val.inspect).to(eq("#<AVR::Value 0>"))
    end
  end

  describe "with custom value" do
    subject(:val) { described_class.new(0x2a) }

    it "has the specified value" do
      expect(val.value).to(eq(42))
    end

    it "has name from the initial integer value" do
      expect(val.name).to(eq("42"))
    end

    it "formats value_hex properly" do
      expect(val.value_hex).to(eq("2a"))
    end

    it "allows changing the value" do
      val.value = 0xff
      expect(val.value).to(eq(255))
      expect(val.value_hex).to(eq("ff"))
      expect(val.to_i).to(eq(255))
    end
  end
end
