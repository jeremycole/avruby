# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Device) do
  describe ".devices" do
    it "registers loaded device types" do
      expect(described_class.devices).to(include(
        Arduino_Uno_R3: AVR::Device::Arduino_Uno_R3,
        Atmel_ATmega328p: AVR::Device::Atmel_ATmega328p,
        Atmel_ATmega32u4: AVR::Device::Atmel_ATmega32u4,
        Atmel_ATmega644pa: AVR::Device::Atmel_ATmega644pa
      ))
    end

    it "automatically registers new subclasses" do
      class CustomRegisteredDevice < AVR::Device # rubocop:disable RSpec/LeakyConstantDeclaration, Lint/ConstantDefinitionInBlock
        abstract!
      end

      expect(described_class.devices[:CustomRegisteredDevice]).to(eq(CustomRegisteredDevice))
    end
  end
end
