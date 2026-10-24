# typed: strict
# frozen_string_literal: true

module AVR
  class PC < Value
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :size

    sig do
      params(
        size: Integer
      ).void
    end
    def initialize(size)
      @size = size
      super()
    end

    sig { returns(Integer) }
    def size_in_bytes
      size * 2
    end

    sig { returns(Integer) }
    def value_in_bytes
      value * 2
    end

    sig { returns(String) }
    def format
      "%04x"
    end

    sig { params(new_value: Integer).void }
    def value=(new_value)
      super(new_value % size)
    end

    sig { params(offset: Integer).returns(Integer) }
    def adjust(offset)
      self.value = value + offset
      value
    end

    sig { params(by: Integer).returns(Integer) }
    def decrement(by = 1)
      adjust(-by)
    end

    sig { params(by: Integer).returns(Integer) }
    def increment(by = 1)
      adjust(+by)
    end

    sig { params(other: Object).returns(T::Boolean) }
    def ==(other)
      case other
      when PC, Value
        value == other.value
      when Integer
        value == other
      else
        false
      end
    end
  end
end
