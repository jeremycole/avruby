# typed: strict
# frozen_string_literal: true

module AVR
  class MemoryByteRegisterWithNamedBits < MemoryByteRegister
    extend T::Sig

    sig { returns(T::Array[T.nilable(Symbol)]) }
    attr_reader :bit_names

    sig { returns(T::Hash[Symbol, Integer]) }
    attr_reader :bit_names_bv

    sig { params(cpu: CPU, name: Symbol, memory_byte: MemoryByte, bit_names: T::Array[T.nilable(Symbol)]).void }
    def initialize(cpu, name, memory_byte, bit_names)
      super(cpu, name, memory_byte)

      @bit_names = bit_names
      @bit_names_bv = T.let(
        @bit_names.each_with_index.with_object({}) { |(b, i), h| h[b] = 2**i if b },
        T::Hash[Symbol, Integer]
      )
    end

    sig { params(bit_name: Symbol).returns(Integer) }
    def get(bit_name)
      bit_value = T.must(@bit_names_bv[bit_name])
      (value & bit_value) == 0 ? 0 : 1
    end

    sig { params(bit_name: Symbol).returns(T::Boolean) }
    def set?(bit_name)
      get(bit_name) == 1
    end

    sig { params(bit_name: Symbol, new_value: Integer).void }
    def set(bit_name, new_value)
      raise "Bad value #{new_value} for bit #{bit_name}" unless [1, 0].include?(new_value)

      bit_value = T.must(@bit_names_bv[bit_name])
      if new_value == 1
        self.value |= bit_value
      else
        self.value &= ~bit_value
      end

      nil
    end

    sig { returns(T::Hash[Symbol, Integer]) }
    def bits
      bit_names.compact.to_h { |name| [name, fetch_bit(name)] }
    end

    sig { params(name: Symbol).returns(Integer) }
    def fetch(name)
      get(name)
    end

    sig { params(name: Symbol).returns(Integer) }
    def fetch_bit(name)
      fetch(name)
    end

    sig { params(flags: T::Array[Symbol]).returns(Integer) }
    def mask_for_flags(flags)
      mask = 0
      flags.each { |flag| mask |= T.must(@bit_names_bv[flag]) }
      mask
    end

    sig { returns(String) }
    def bit_values
      @bit_names.compact.map { |name| name.to_s + "=" + get(name).to_s }.join(", ")
    end

    sig { params(value: Integer).returns(T::Hash[Symbol, Integer]) }
    def hash_for_value(value)
      @bit_names_bv.each_with_object({}) { |(name, bv), hash| hash[name] = (value & bv != 0) }
    end

    sig { params(hash: T::Hash[Symbol, Integer]).returns([Integer, Integer]) }
    def value_for_hash(hash)
      mask = 0
      sum = 0
      hash.each do |name, status|
        mask |= T.must(@bit_names_bv[name])
        sum |= T.must(@bit_names_bv[name]) if [true, 1].include?(status)
      end
      [mask, sum]
    end

    sig { void }
    def reset
      self.value = 0
    end

    sig { params(hash: T::Hash[Symbol, Integer]).returns(MemoryByteRegisterWithNamedBits) }
    def from_h(hash)
      mask, sum = value_for_hash(hash)
      self.value = (value & ~mask) | sum
      self
    end

    sig { returns(String) }
    def inspect
      "#<#{self.class.name} #{bit_values}>"
    end

    sig { params(old_value: Integer, new_value: Integer).returns(String) }
    def diff_values(old_value, new_value)
      diff_mask = old_value ^ new_value
      diff_strings = []
      @bit_names_bv.each do |flag, mask|
        old_bit = (old_value & mask) != 0 ? 1 : 0
        new_bit = (new_value & mask) != 0 ? 1 : 0
        diff_strings << "#{flag}=#{old_bit}->#{new_bit}" if diff_mask & mask != 0
      end
      "[#{diff_strings.join(', ')}]"
    end
  end
end
