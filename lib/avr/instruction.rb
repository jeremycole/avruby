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

    def valid?
      raise "No opcode available" unless opcode
      raise "Wrong number of arguments" unless opcode.arg_types && opcode.arg_types.size == args.size
      true
    end

    def args_to_s
      return args.join(", ") unless opcode
      return nil unless opcode.arg_types.size > 0
      arg_strings = []
      opcode.arg_types.each_with_index.map do |arg_type, i|
        case arg_type
        when :register
          arg_strings << args[i].name
        when :constant, :io_address
          arg_strings << ("0x%02x" % [args[i]])
        when :pc
          arg_strings << ("0x%04x" % [args[i]])
        when :offset
          arg_strings << (".%+d" % [2 * args[i]])
        else
          arg_strings << args[i].to_s
        end
      end
      arg_strings.join(", ")
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
