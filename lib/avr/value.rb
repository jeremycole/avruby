# typed: strict
# frozen_string_literal: true

module AVR
  class Value
    extend T::Sig

    sig { returns(T.any(String, Symbol)) }
    attr_reader :name

    sig { returns(Integer) }
    attr_accessor :value

    sig { params(value: Integer).void }
    def initialize(value = 0)
      @name = T.let(value.to_s, String)
      @value = T.let(value, Integer)
    end

    sig { returns(String) }
    def format
      "%02x"
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
