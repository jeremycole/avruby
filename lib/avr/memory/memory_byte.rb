# typed: strict
# frozen_string_literal: true

module AVR
  class MemoryByte
    extend T::Sig

    sig { returns(Memory) }
    attr_reader :memory

    sig { returns(Integer) }
    attr_reader :address

    sig { returns(Integer) }
    attr_reader :value

    sig { params(memory: Memory, address: Integer, value: Integer).void }
    def initialize(memory, address, value)
      @memory = memory
      @address = address
      @value = value
    end

    sig { returns(String) }
    def format
      '%02x'
    end

    sig { returns(Integer) }
    def to_i
      value.to_i
    end

    sig { returns(String) }
    def to_s
      value.to_s
    end

    sig { returns(String) }
    def chr
      value.chr
    end

    sig { params(new_value: Integer).void }
    def value=(new_value)
      return if new_value == value
      raise "Value #{new_value} out of range" unless (0..255).include?(new_value)

      old_value = value
      @value = new_value
      memory.notify(self, old_value, new_value)
    end
  end
end
