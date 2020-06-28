# typed: strict
# frozen_string_literal: true

# rubocop:disable Naming/MethodParameterName
module AVR
  class RegisterPair < Register
    extend T::Sig

    sig { returns(MemoryByteRegister) }
    attr_reader :l

    sig { returns(MemoryByteRegister) }
    attr_reader :h

    sig do
      params(
        cpu: CPU,
        l: MemoryByteRegister,
        h: MemoryByteRegister,
        name: T.nilable(T.any(Symbol, String))
      ).void
    end
    def initialize(cpu, l, h, name = nil)
      super(cpu, name || "Temporary[#{l.name}, #{h.name}]")
      @l = l
      @h = h
    end

    sig { returns(String) }
    def format
      '%04x'
    end

    sig { returns(Integer) }
    def value
      (h.value << 8) | l.value
    end

    sig { params(new_value: Integer).void }
    def value=(new_value)
      h.value = (new_value & 0xff00) >> 8
      l.value = (new_value & 0x00ff)
    end
  end
end
# rubocop:enable Naming/MethodParameterName
