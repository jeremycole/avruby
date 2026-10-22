# typed: strict
# frozen_string_literal: true

require "intel_hex"

module AVR
  class Memory
    extend T::Sig
    extend T::Helpers

    abstract!

    sig { returns(String) }
    attr_reader :name

    sig { returns(Integer) }
    attr_reader :size

    sig { params(name: String, size: Integer).void }
    def initialize(name, size)
      @name = name
      @size = size
    end

    sig { abstract.params(address: Integer).returns(MemoryByte) }
    def [](address); end

    sig { returns(String) }
    def inspect
      "#<#{self.class.name} size=#{size}>"
    end

    sig { params(address: Integer).returns(Integer) }
    def word(address)
      byte_address = address << 1
      (self[byte_address + 1].value << 8) | self[byte_address].value
    end

    sig { params(address: Integer, value: Integer).void }
    def set_word(address, value)
      byte_address = address << 1
      self[byte_address + 1].value = (value & 0xff00) >> 8
      self[byte_address].value = value & 0x00ff
    end

    sig { params(filename: String).returns(Integer) }
    def load_from_intel_hex(filename)
      ihex = IntelHex::FileReader.new(filename)
      sum = 0
      ihex.each_byte_with_address do |byte, address|
        self[address].value = byte
        sum += 1
      end
      sum
    end
  end
end
