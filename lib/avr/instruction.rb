module AVR
  class Instruction
    attr_reader :cpu
    attr_reader :memory
    attr_reader :offset
    attr_reader :mnemonic
    attr_reader :args
    attr_reader :opcode
  
    def initialize(cpu, memory, offset, mnemonic, *args)
      @cpu = cpu
      @memory = memory
      @offset = offset
      @mnemonic = mnemonic
      @args = args
      @opcode = AVR::Opcode::OPCODES[mnemonic]
    end

    def validate
      opcode.validate(cpu, args)
    end

    def valid?
      raise "No opcode available" unless opcode
      validate
      true
    end

    def args_to_s
      return args.join(", ") unless opcode
      return nil unless opcode.arg_types.size > 0
      opcode.format_args(args).join(", ")
    end

    def to_s
      return mnemonic.to_s if args.size == 0
      mnemonic.to_s + " " + args_to_s
    end

    def inspect
      "#<#{self.class.name} {#{to_s}} @ #{memory.name}[#{offset}]>"
    end

    def execute
      raise "Invalid instruction" unless valid?
      opcode.execute(cpu, memory, offset, args)
    end
  end
end
