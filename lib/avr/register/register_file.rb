# typed: strict
# frozen_string_literal: true

module AVR
  class RegisterFile
    extend T::Sig

    sig { returns(CPU) }
    attr_reader :cpu

    sig { returns(T::Hash[Symbol, Register]) }
    attr_reader :registers

    sig { returns(T::Hash[Register, RegisterPair]) }
    attr_reader :word_register_map

    sig { returns(T::Array[Symbol]) }
    attr_reader :register_list

    sig { params(register: Register).void }
    def add(register)
      @registers[register.name] = register
      @register_list << register.name
      return unless register.is_a?(RegisterPair)

      @word_register_map[register.l] = register
      @word_register_map[register.h] = register
    end

    sig { params(cpu: CPU).void }
    def initialize(cpu)
      @cpu = cpu
      @registers = T.let({}, T::Hash[Symbol, Register])
      @word_register_map = T.let({}, T::Hash[Register, RegisterPair])
      @register_list = T.let([], T::Array[Symbol])
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

    sig { params(key: T.any(Integer, Symbol)).returns(T::Boolean) }
    def key?(key)
      if key.is_a?(Integer)
        key >= 0 && key < @register_list.length
      else
        @registers.key?(key)
      end
    end
    alias include? key?
    alias has_key? key?

    sig { returns(T::Array[Symbol]) }
    def keys
      @registers.keys
    end

    sig { returns(T::Array[Register]) }
    def values
      @registers.values
    end

    sig { params(block: T.proc.params(register: Register).void).void }
    # rubocop:disable-next Naming/BlockForwarding,Style/ArgumentsForwarding
    def each_value(&block)
      @registers.each_value(&block)
    end

    sig { params(key: T.any(Integer, Symbol)).returns(T.nilable(Register)) }
    def fetch(key)
      if key.is_a?(Integer)
        name = @register_list[key]
        name ? @registers.fetch(name, nil) : nil
      else
        @registers.fetch(key, nil)
      end
    end

    sig { params(key: T.any(Integer, Symbol)).returns(T.nilable(Register)) }
    def [](key)
      if key.is_a?(Integer)
        name = @register_list[key]
        name ? @registers[name] : nil
      else
        @registers[key]
      end
    end

    sig { params(key: T.any(Integer, Symbol), value: Integer).returns(Integer) }
    def []=(key, value)
      reg = self[key]
      raise KeyError, "Register not found for #{key}" unless reg

      reg.value = value
      value
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
