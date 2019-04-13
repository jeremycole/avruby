module AVR
  class Opcode
    attr_reader :mnemonic
    attr_reader :arg_types
    attr_reader :opcode_proc

    def initialize(mnemonic, arg_types, opcode_proc)
      @mnemonic = mnemonic
      @arg_types = arg_types
      @opcode_proc = opcode_proc
    end

    def inspect
      "#<#{self.class.name} #{mnemonic} #{arg_types}>"
    end

    def execute(cpu, memory, offset, args)
      opcode_proc.call(cpu, memory, offset, args)
    end

    OPCODES = {}

    def self.opcode(mnemonic, arg_types=[], &block)
      raise "No block given" unless block_given?
      OPCODES[mnemonic] = Opcode.new(mnemonic, arg_types, block.to_proc)
    end
  end
end

require "avr/opcode/nop"
require "avr/opcode/register"
require "avr/opcode/data/stack"
require "avr/opcode/data/immediate"
require "avr/opcode/branch/unconditional"
require "avr/opcode/branch/conditional"
require "avr/opcode/math/addition"
require "avr/opcode/math/subtraction"
require "avr/opcode/math/bitwise"
require "avr/opcode/io/bit"
require "avr/opcode/io/in_out"
