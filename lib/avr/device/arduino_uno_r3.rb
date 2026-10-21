# typed: strict
# frozen_string_literal: true

module AVR
  class Device
    class Arduino_Uno_R3 < Atmel_ATmega328p # rubocop:disable Naming/ClassAndModuleCamelCase
      extend T::Sig

      sig { override.returns(T::Hash[Symbol, Integer]) }
      def fuse_default_values
        @fuse_default_values ||= {
          LOW:      0x62,
          HIGH:     0xd9,
          EXTENDED: 0xff,
        }.freeze
      end
    end
  end
end