# typed: strict
# frozen_string_literal: true

require "forwardable"

module AVR
  class RegisterWithDisplacement < Value
    extend Forwardable
    extend T::Sig

    sig { returns(Register) }
    attr_reader :register

    def_delegators :register, :value, :value=

    sig { returns(Integer) }
    attr_reader :displacement

    sig { params(register: Register, displacement: Integer).void }
    def initialize(register, displacement)
      @register = register
      @displacement = displacement
      super()
    end

    sig { returns(String) }
    def name
      format("%s%+d", register.name, displacement)
    end
  end
end
