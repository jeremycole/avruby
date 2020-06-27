# typed: true
# frozen_string_literal: true

module AVR
  class MemoryByte
    attr_reader :memory
    attr_reader :address
    attr_reader :value

    def initialize(memory, address, value)
      @memory = memory
      @address = address
      @value = value
    end

    def format
      '%02x'
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

    def value=(new_value)
      return if new_value == value
      raise "Value #{new_value} out of range" unless (0..255).include?(new_value)

      old_value = value
      @value = new_value
      memory.notify(self, old_value, new_value)
    end
  end
end
