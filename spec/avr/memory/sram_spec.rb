# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Memory::SRAM) do
  subject(:sram) { described_class.new(512) }

  it "initializes with name 'SRAM' and requested size" do
    expect(sram.name).to(eq("SRAM"))
    expect(sram.size).to(eq(512))
  end

  it "initializes all bytes to 0x00 by default" do
    expect(sram[0].value).to(eq(0x00))
    expect(sram[511].value).to(eq(0x00))
  end
end
