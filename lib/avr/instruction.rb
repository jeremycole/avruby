# typed: strict
# frozen_string_literal: true

module AVR
  class Instruction
    extend T::Sig

    sig { returns(CPU) }
    attr_reader :cpu

    sig { returns(Symbol) }
    attr_reader :mnemonic

    sig { returns(Argument::ArrayType) }
    attr_reader :args

    sig { returns(Opcode) }
    attr_reader :opcode

    sig { params(cpu: CPU, mnemonic: Symbol, args: Argument::ArrayType).void }
    def initialize(cpu, mnemonic, args)
      raise "Unknown opcode #{mnemonic}" unless Opcode.opcodes.include?(mnemonic)

      @cpu = cpu
      @mnemonic = mnemonic
      @args = args
      @opcode = T.let(Opcode.opcodes.fetch(mnemonic), Opcode)
    end

    sig { returns(T::Boolean) }
    def validate
      opcode.validate(args)
    end

    sig { returns(T::Boolean) }
    def valid?
      validate
      true
    end

    sig { returns(T.nilable(String)) }
    def args_to_s
      # return args.join(', ') unless opcode
      return nil if opcode.arg_types.empty?

      opcode.format_args(args).join(", ")
    end

    sig { returns(String) }
    def to_s
      return mnemonic.to_s if args.empty?

      "#{mnemonic} #{args_to_s}"
    end

    sig { returns(String) }
    def inspect
      "#<#{self.class.name} {#{self}}>"
    end

    sig { void }
    def execute
      raise "Invalid instruction" unless valid?

      cpu.next_pc = cpu.pc + 1
      opcode.execute(cpu, nil, args)
      cpu.pc = cpu.next_pc

      nil
    end
  end
end
