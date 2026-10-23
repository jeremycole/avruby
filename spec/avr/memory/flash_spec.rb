# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Memory::Flash) do
  subject(:flash) { described_class.new(1024) }

  it "initializes with name 'Flash' and requested size" do
    expect(flash.name).to(eq("Flash"))
    expect(flash.size).to(eq(1024))
  end

  it "initializes all bytes to 0xff by default" do
    expect(flash[0].value).to(eq(0xff))
    expect(flash[1023].value).to(eq(0xff))
  end
end
