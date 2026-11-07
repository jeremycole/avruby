# typed: strict
# frozen_string_literal: true

module AVR
  class SREG < MemoryByteRegisterWithNamedBits
    extend T::Sig

    STATUS_BITS = T.let([:C, :Z, :N, :V, :S, :H, :T, :I].freeze, T::Array[Symbol])

    sig { returns(Integer) }
    def C
      get(:C)
    end

    sig { returns(T::Boolean) }
    def C?
      get(:C) == 1
    end

    sig { params(value: Integer).void }
    def C=(value)
      set(:C, value)
    end

    sig { returns(Integer) }
    def Z
      get(:Z)
    end

    sig { returns(T::Boolean) }
    def Z?
      get(:Z) == 1
    end

    sig { params(value: Integer).void }
    def Z=(value)
      set(:Z, value)
    end

    sig { returns(Integer) }
    def N
      get(:N)
    end

    sig { returns(T::Boolean) }
    def N?
      get(:N) == 1
    end

    sig { params(value: Integer).void }
    def N=(value)
      set(:N, value)
    end

    sig { returns(Integer) }
    def V
      get(:V)
    end

    sig { returns(T::Boolean) }
    def V?
      get(:V) == 1
    end

    sig { params(value: Integer).void }
    def V=(value)
      set(:V, value)
    end

    sig { returns(Integer) }
    def S
      get(:S)
    end

    sig { returns(T::Boolean) }
    def S?
      get(:S) == 1
    end

    sig { params(value: Integer).void }
    def S=(value)
      set(:S, value)
    end

    sig { returns(Integer) }
    def H
      get(:H)
    end

    sig { returns(T::Boolean) }
    def H?
      get(:H) == 1
    end

    sig { params(value: Integer).void }
    def H=(value)
      set(:H, value)
    end

    sig { returns(Integer) }
    def T
      get(:T)
    end

    sig { returns(T::Boolean) }
    def T?
      get(:T) == 1
    end

    sig { params(value: Integer).void }
    def T=(value)
      set(:T, value)
    end

    sig { returns(Integer) }
    def I
      get(:I)
    end

    sig { returns(T::Boolean) }
    def I?
      get(:I) == 1
    end

    sig { params(value: Integer).void }
    def I=(value)
      set(:I, value)
    end

    sig { params(cpu: CPU).void }
    def initialize(cpu)
      super(cpu, "SREG", cpu.data_address_space[T.must(cpu.device.register_memory_map[:SREG])], STATUS_BITS)
    end
  end
end
