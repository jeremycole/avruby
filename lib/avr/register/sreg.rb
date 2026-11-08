# typed: strict
# frozen_string_literal: true

module AVR
  class SREG < MemoryByteRegisterWithNamedBits
    extend T::Sig

    STATUS_BITS = T.let([:C, :Z, :N, :V, :S, :H, :T, :I].freeze, T::Array[Symbol])

    sig { returns(Integer) }
    def C # rubocop:disable Naming/MethodName
      get(:C)
    end

    sig { returns(T::Boolean) }
    def C? # rubocop:disable Naming/MethodName
      get(:C) == 1
    end

    sig { params(value: Integer).void }
    def C=(value) # rubocop:disable Naming/MethodName
      set(:C, value)
    end

    sig { returns(Integer) }
    def Z # rubocop:disable Naming/MethodName
      get(:Z)
    end

    sig { returns(T::Boolean) }
    def Z? # rubocop:disable Naming/MethodName
      get(:Z) == 1
    end

    sig { params(value: Integer).void }
    def Z=(value) # rubocop:disable Naming/MethodName
      set(:Z, value)
    end

    sig { returns(Integer) }
    def N # rubocop:disable Naming/MethodName
      get(:N)
    end

    sig { returns(T::Boolean) }
    def N? # rubocop:disable Naming/MethodName
      get(:N) == 1
    end

    sig { params(value: Integer).void }
    def N=(value) # rubocop:disable Naming/MethodName
      set(:N, value)
    end

    sig { returns(Integer) }
    def V # rubocop:disable Naming/MethodName
      get(:V)
    end

    sig { returns(T::Boolean) }
    def V? # rubocop:disable Naming/MethodName
      get(:V) == 1
    end

    sig { params(value: Integer).void }
    def V=(value) # rubocop:disable Naming/MethodName
      set(:V, value)
    end

    sig { returns(Integer) }
    def S # rubocop:disable Naming/MethodName
      get(:S)
    end

    sig { returns(T::Boolean) }
    def S? # rubocop:disable Naming/MethodName
      get(:S) == 1
    end

    sig { params(value: Integer).void }
    def S=(value) # rubocop:disable Naming/MethodName
      set(:S, value)
    end

    sig { returns(Integer) }
    def H # rubocop:disable Naming/MethodName
      get(:H)
    end

    sig { returns(T::Boolean) }
    def H? # rubocop:disable Naming/MethodName
      get(:H) == 1
    end

    sig { params(value: Integer).void }
    def H=(value) # rubocop:disable Naming/MethodName
      set(:H, value)
    end

    sig { returns(Integer) }
    def T # rubocop:disable Naming/MethodName
      get(:T)
    end

    sig { returns(T::Boolean) }
    def T? # rubocop:disable Naming/MethodName
      get(:T) == 1
    end

    sig { params(value: Integer).void }
    def T=(value) # rubocop:disable Naming/MethodName
      set(:T, value)
    end

    sig { returns(Integer) }
    def I # rubocop:disable Naming/MethodName
      get(:I)
    end

    sig { returns(T::Boolean) }
    def I? # rubocop:disable Naming/MethodName
      get(:I) == 1
    end

    sig { params(value: Integer).void }
    def I=(value) # rubocop:disable Naming/MethodName
      set(:I, value)
    end

    sig { params(cpu: CPU).void }
    def initialize(cpu)
      super(cpu, :SREG, cpu.data_address_space[T.must(cpu.device.register_memory_map[:SREG])], STATUS_BITS)
    end
  end
end
