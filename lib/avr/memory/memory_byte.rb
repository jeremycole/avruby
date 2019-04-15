module AVR
  class MemoryByte
    attr_reader :memory
    attr_reader :address

    def initialize(memory, address, value)
      @memory = memory
      @address = address
      @value = value
    end

    def format
      "%02x"
    end

    def to_i
      value.to_i
    end

    def to_s
      value.to_s
    end

    def chr
      value.chr
    end

    def value
      @value
    end

    def value=(new_value)
      return if new_value == value
      raise "Value #{new_value} out of range" if new_value < 0 || new_value > 255
      old_value = value
      @value = new_value
      memory.notify(self, old_value, new_value)
      @value
    end
  end
end