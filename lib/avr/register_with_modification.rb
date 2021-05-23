# typed: strict
# frozen_string_literal: true

require "forwardable"

module AVR
  class RegisterWithModification < Value
    extend Forwardable
    extend T::Sig

    sig { returns(Register) }
    attr_reader :register

    def_delegators :register, :value, :value=

    sig { returns(Symbol) }
    attr_reader :modification

    sig { params(register: Register, modification: T.nilable(Symbol)).void }
    def initialize(register, modification = :none)
      @register = register
      @modification = T.let(T.must(modification), Symbol)
      super()
    end

    sig { returns(String) }
    def name
      [
        (modification == :pre_decrement ? "-" : ""),
        register.to_s,
        (modification == :post_increment ? "+" : ""),
      ].join
    end
  end
end
