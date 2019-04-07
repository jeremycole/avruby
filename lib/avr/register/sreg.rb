module AVR
  class SREG < MemoryByteRegister
    STATUS_BITS = [:C, :Z, :N, :V, :S, :H, :T, :I]

    def initialize(cpu, memory_byte)
      super(cpu, "SREG", memory_byte)
      value = 0

      STATUS_BITS.each_with_index do |name, bit_value|
        self.class.send(:define_method, name, proc {
          (self.value & (1 << bit_value)) == (1 << bit_value)
        })

        self.class.send(:define_method, (name.to_s + "=").to_sym, proc { |new_value|
          if new_value == true || new_value == 1
            self.value |= (1 << bit_value)
          elsif new_value == false || new_value == 0
            self.value &= ~(1 << bit_value)
          else
            raise "Bad value #{new_value} for SREG bit #{name}"
          end
        })
      end
    end

    def bit_values
      STATUS_BITS.map { |name| name.to_s + "=" + (send(name) ? "1" : "0") }.join(", ")
    end

    def inspect
      "#<#{self.class.name} #{bit_values}>"
    end
  end
end