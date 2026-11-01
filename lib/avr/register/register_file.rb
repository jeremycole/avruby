# typed: strict
# frozen_string_literal: true

module AVR
  class RegisterFile
    extend T::Sig

    sig { returns(CPU) }
    attr_reader :cpu

    sig { returns(T::Hash[T.any(Symbol, String), Register]) }
    attr_reader :registers

    sig { returns(T::Hash[Register, RegisterPair]) }
    attr_reader :word_register_map

    sig { returns(T::Array[T.any(Symbol, String)]) }
    attr_reader :register_list

    sig { params(register: Register).void }
    def add(register)
      @registers[register.name] = register
      @cpu.send(:define_singleton_method, register.name.to_sym, proc { register })
      @cpu.send(:define_singleton_method, (register.name.to_s + "=").to_sym, proc { |value| register.value = value })
      @register_list << register.name
      return unless register.is_a?(RegisterPair)

      @word_register_map[register.l] = register
      @word_register_map[register.h] = register
    end

    sig { params(cpu: CPU).void }
    def initialize(cpu)
      @cpu = cpu
      @registers = T.let({}, T::Hash[T.any(Symbol, String), Register])
      @word_register_map = T.let({}, T::Hash[Register, RegisterPair])
      @register_list = T.let([], T::Array[T.any(Symbol, String)])
    end

    sig { void }
    def reset
      @registers.each_value do |register|
        register.value = 0
      end
    end

    sig { returns(String) }
    def register_values
      @register_list.map { |name| @registers[name].to_s }.join(", ")
    end

    sig { void }
    def print_status
      @register_list.each_slice(4) do |slice|
        puts slice.map { |name| format("%8s=%-4s", name, T.must(@registers[name]).value_hex) }.join(" ") + "\n"
      end
    end

    sig { params(key: T.any(Integer, Symbol)).returns(T.nilable(Register)) }
    def fetch(key)
      @registers.fetch(@register_list.fetch(key)) if key.is_a?(Integer)
    end

    sig { params(key: T.any(Integer, Symbol)).returns(T.nilable(Register)) }
    def [](key)
      @registers[T.must(@register_list[key])] if key.is_a?(Integer)
    end

    sig { params(register: Register).returns(T.nilable(RegisterPair)) }
    def associated_word_register(register)
      @word_register_map[register]
    end

    sig { returns(String) }
    def inspect
      "#<#{self.class.name} #{register_values}>"
    end
  end
end
