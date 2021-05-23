# typed: strict
# frozen_string_literal: true

module AVR
  module Argument
    extend T::Sig

    ValueType = T.type_alias do
      T.any(
        Value,
        Register,
        RegisterPair,
        RegisterWithBitNumber,
        RegisterWithDisplacement,
        RegisterWithModification,
        RegisterWithNamedBit,
        MemoryByteRegister,
        MemoryByteRegisterWithNamedBits
      )
    end
    ArrayType = T.type_alias { T::Array[ValueType] }
    NamedValueType = T.type_alias { T::Hash[Symbol, ValueType] }
  end
end
