# typed: strict
# frozen_string_literal: true

module AVR
  class Device
    class Arduino_Uno_R3 < Atmel_ATmega328p # rubocop:disable Naming/ClassAndModuleCamelCase
      extend T::Sig

      sig { override.returns(T::Hash[Symbol, Integer]) }
      def fuse_default_values
        @fuse_default_values ||= {
          LOW:      0xff,
          HIGH:     0xde,
          EXTENDED: 0x05,
        }.freeze
      end
    end
  end
end
