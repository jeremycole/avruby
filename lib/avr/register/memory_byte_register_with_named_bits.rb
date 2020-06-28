# typed: true
# frozen_string_literal: true

module AVR
  class MemoryByteRegisterWithNamedBits < MemoryByteRegister
    attr_reader :bit_names

    def initialize(cpu, name, memory_byte, bit_names)
      super(cpu, name, memory_byte)
      @bit_names = bit_names
      @bit_names_bv = @bit_names.each_with_index.each_with_object({}) { |(b, i), h| h[b] = 2**i if b }

      @bit_names_bv.each do |bit_name, bit_value|
        define_singleton_method(bit_name, proc { (value & bit_value) == bit_value })

        define_singleton_method((bit_name.to_s + '=').to_sym, proc { |new_value|
          if [true, 1].include?(new_value)
            self.value |= bit_value
          elsif [false, 0].include?(new_value)
            self.value &= ~bit_value
          else
            raise "Bad value #{new_value} for bit #{bit_name}"
          end
        })
      end
    end

    def fetch(name)
      send(name)
    end

    def fetch_bit(name)
      fetch(name) ? 1 : 0
    end

    def mask_for_flags(flags)
      mask = 0
      flags.each { |flag| mask |= @bit_names_bv[flag] }
      mask
    end

    def bit_values
      @bit_names.reject(&:nil?).map { |name| name.to_s + '=' + (send(name) ? '1' : '0') }.join(', ')
    end

    def hash_for_value(value)
      @bit_names_bv.each_with_object({}) { |(name, bv), hash| hash[name] = (value & bv != 0) }
    end

    def value_for_hash(hash)
      mask = 0
      sum = 0
      hash.each do |name, status|
        mask |= @bit_names_bv[name]
        sum |= @bit_names_bv[name] if [true, 1].include?(status)
      end
      [mask, sum]
    end

    def reset
      self.value = 0
    end

    def from_h(hash)
      mask, sum = value_for_hash(hash)
      self.value = (value & ~mask) | sum
      self
    end

    def inspect
      "#<#{self.class.name} #{bit_values}>"
    end

    def diff_values(old_value, new_value)
      diff_mask = old_value ^ new_value
      diff_strings = []
      @bit_names_bv.each do |flag, mask|
        old_bit = (old_value & mask) != 0 ? 1 : 0
        new_bit = (new_value & mask) != 0 ? 1 : 0
        diff_strings << "#{flag}=#{old_bit}->#{new_bit}" if diff_mask & mask != 0
      end
      '[' + diff_strings.join(', ') + ']'
    end
  end
end
