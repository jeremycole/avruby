# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module AVR
  class Register < Value
    extend T::Sig

    sig { returns(CPU) }
    attr_reader :cpu

    sig { override.returns(Symbol) }
    attr_reader :name

    sig { params(cpu: CPU, name: Symbol).void }
    def initialize(cpu, name)
      super()
      @cpu = cpu
      @name = name
    end
  end
end
