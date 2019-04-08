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

require "avr/opcode/subi_sbci"
require "avr/opcode/brbs_brbc"
require "avr/opcode/sbi_cbi"
require "avr/opcode/jmp"
require "avr/opcode/add"
require "avr/opcode/eor"
require "avr/opcode/mov"
require "avr/opcode/nop"
require "avr/opcode/push_pop"
require "avr/opcode/ldi"
require "avr/opcode/in_out"
require "avr/opcode/call"