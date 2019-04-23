module AVR
  class MemoryByteRegisterWithNamedBits < MemoryByteRegister
    attr_reader :bit_names

    def initialize(cpu, name, memory_byte, bit_names)
      super(cpu, name, memory_byte)
      @bit_names = bit_names
      @bit_names_bv = @bit_names.each_with_index.each_with_object({}) { |(b, i), h| h[b] = 2**i if b }
      value = 0

      @bit_names_bv.each do |name, bit_value|
        define_singleton_method(name, proc {
          (self.value & bit_value) == bit_value
        })

        define_singleton_method((name.to_s + "=").to_sym, proc { |new_value|
          if new_value == true || new_value == 1
            self.value |= bit_value
          elsif new_value == false || new_value == 0
            self.value &= ~bit_value
          else
            raise "Bad value #{new_value} for bit #{name}"
          end
        })
      end
    end

    def mask_for_flags(flags)
      mask = 0
      flags.each { |flag| mask |= @bit_names_bv[flag] }
      mask
    end

    def bit_values
      @bit_names.reject(&:nil?).map { |name| name.to_s + "=" + (send(name) ? "1" : "0") }.join(", ")
    end

    def hash_for_value(value)
      @bit_names_bv.each_with_object({}) { |(name, bv), hash| hash[name] = (value & bv != 0) }
    end

    def value_for_hash(hash)
      mask = 0
      sum = 0
      hash.each do |name, status|
        mask |= @bit_names_bv[name]
        sum |= @bit_names_bv[name] if status == true || status == 1
      end
      [mask, sum]
    end

    def reset
      self.value = 0
    end

    def set_by_hash(hash)
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
        old_bit = ((old_value & mask) != 0) ? 1 : 0
        new_bit = ((new_value & mask) != 0) ? 1 : 0
        if diff_mask & mask != 0
          diff_strings << "#{flag}=#{old_bit}->#{new_bit}"
        end
      end
      "[" + diff_strings.join(", ") + "]"
    end
  end
end