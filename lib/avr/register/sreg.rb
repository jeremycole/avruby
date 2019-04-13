module AVR
  class SREG < MemoryByteRegister
    STATUS_BITS = [:C, :Z, :N, :V, :S, :H, :T, :I]
    STATUS_BITS_BV = STATUS_BITS.each_with_index.
      each_with_object({}) { |(b, i), h| h[b] = 2**i }

    def initialize(cpu, memory_byte)
      super(cpu, "SREG", memory_byte)
      value = 0

      STATUS_BITS_BV.each do |name, bit_value|
        define_singleton_method(name, proc {
          (self.value & bit_value) == bit_value
        })

        define_singleton_method((name.to_s + "=").to_sym, proc { |new_value|
          if new_value == true || new_value == 1
            self.value |= bit_value
          elsif new_value == false || new_value == 0
            self.value &= ~bit_value
          else
            raise "Bad value #{new_value} for SREG bit #{name}"
          end
        })
      end
    end

    def bit_values
      STATUS_BITS.map { |name| name.to_s + "=" + (send(name) ? "1" : "0") }.join(", ")
    end

    def value_for_hash(hash)
      mask = 0
      sum = 0
      hash.each do |name, status|
        mask |= STATUS_BITS_BV[name]
        sum |= STATUS_BITS_BV[name] if status == true || status == 1
      end
      [mask, sum]
    end

    def set_by_hash(hash)
      mask, sum = value_for_hash(hash)
      self.value = (value & ~mask) | sum
      self
    end

    def inspect
      "#<#{self.class.name} #{bit_values}>"
    end
  end
end