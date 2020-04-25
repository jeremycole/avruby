# frozen_string_literal: true

module AVR
  class Instruction
    attr_reader :cpu
    attr_reader :memory
    attr_reader :offset
    attr_reader :mnemonic
    attr_reader :args
    attr_reader :opcode

    def initialize(cpu, mnemonic, *args)
      @cpu = cpu
      @mnemonic = mnemonic
      @args = args
      @opcode = AVR::Opcode::OPCODES[mnemonic]
    end

    def validate
      opcode.validate(args)
    end

    def valid?
      raise 'No opcode available' unless opcode

      validate
      true
    end

    def args_to_s
      return args.join(', ') unless opcode
      return nil if opcode.arg_types.empty?

      opcode.format_args(args).join(', ')
    end

    def to_s
      return mnemonic.to_s if args.empty?

      "#{mnemonic} #{args_to_s}"
    end

    def inspect
      "#<#{self.class.name} {#{self}}>"
    end

    def execute
      raise 'Invalid instruction' unless valid?

      cpu.next_pc = cpu.pc + 1
      result = opcode.execute(cpu, nil, args)
      cpu.pc = cpu.next_pc
      result
    end
  end
end
