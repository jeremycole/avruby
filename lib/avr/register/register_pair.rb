# typed: strict
# frozen_string_literal: true

# rubocop:disable Naming/MethodParameterName
module AVR
  class RegisterPair < Register
    extend T::Sig

    sig { returns(MemoryByteRegister) }
    attr_reader :h

    sig { returns(MemoryByteRegister) }
    attr_reader :l

    sig do
      params(
        cpu: CPU,
        h: MemoryByteRegister,
        l: MemoryByteRegister,
        name: T.nilable(T.any(Symbol, String))
      ).void
    end
    def initialize(cpu, h, l, name = nil)
      super(cpu, name || "#{h.name}:#{l.name}")
      @h = h
      @l = l
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
