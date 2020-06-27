# typed: true
# frozen_string_literal: true

# rubocop:disable Naming/MethodParameterName
module AVR
  class RegisterPair < Register
    attr_reader :l, :h

    def initialize(cpu, name, l, h)
      super(cpu, name)
      @l = l
      @h = h
    end

    def format
      '%04x'
    end

    def value
      (h.value << 8) | l.value
    end

    def value=(new_value)
      h.value = (new_value & 0xff00) >> 8
      l.value = (new_value & 0x00ff)
    end
  end
end
# rubocop:enable Naming/MethodParameterName
