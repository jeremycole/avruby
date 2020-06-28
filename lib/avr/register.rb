# typed: strict
# frozen_string_literal: true

module AVR
  class Register < Value
    extend T::Sig

    sig { returns(AVR::CPU) }
    attr_reader :cpu

    sig { params(cpu: AVR::CPU, name: T.any(String, Symbol)).void }
    def initialize(cpu, name)
      super()
      @cpu = cpu
      @name = name
    end
  end
end
