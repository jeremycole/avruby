# typed: strict
# frozen_string_literal: true

module AVR
  class Register
    extend T::Sig

    sig { returns(AVR::CPU) }
    attr_reader :cpu

    sig { returns(T.any(String, Symbol)) }
    attr_reader :name

    sig { returns(Integer) }
    attr_accessor :value

    sig { params(cpu: AVR::CPU, name: T.any(String, Symbol)).void }
    def initialize(cpu, name)
      @cpu = cpu
      @name = name
      @value = T.let(0, Integer)
    end

    sig { returns(String) }
    def format
      '%02x'
    end

    sig { returns(String) }
    def value_hex
      format % value
    end

    sig { returns(Integer) }
    def to_i
      value.to_i
    end

    sig { returns(String) }
    def to_s
      name.to_s
    end

    sig { returns(String) }
    def inspect
      "#<#{self.class.name} #{self}>"
    end
  end
end
