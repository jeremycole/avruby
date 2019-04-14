module AVR
  class Opcode
    class OpcodeException < RuntimeError; end
    class IncorrectArgumentCount < OpcodeException; end
    class RegisterExpected < OpcodeException; end
    class UpperRegisterExpected < OpcodeException; end
    class WordRegisterExpected < OpcodeException; end
    class ByteConstantExpected < OpcodeException; end
    class WordConstantExpected < OpcodeException; end
    class IoAddressExpected < OpcodeException; end
    class LowerIoAddressExpected < OpcodeException; end
    class AbsolutePcExpected < OpcodeException; end
    class NearRelativePcExpected < OpcodeException; end
    class FarRelativePcExpected < OpcodeException; end
    class BitNumberExpected < OpcodeException; end
    class StatusRegisterBitExpected < OpcodeException; end
    class ConstantOutOfRange < OpcodeException; end

    OPCODE_ARGUMENT_TYPES = {
      sreg_flag:          "%s",
      near_relative_pc:   proc { |arg| ".%+d" % [2 * arg] },
      far_relative_pc:    proc { |arg| ".%+d" % [2 * arg] },
      absolute_pc:        "0x%04x",
      byte:               "0x%02x",
      word:               "0x%04x",
      register:           "%s",
      word_register:      "%s",
      modifying_word_register: proc { |arg| "%s%s%s" % [
        arg[1] == :pre_decrement ? "-" : "",
        arg[0].to_s,
        arg[1] == :post_increment ? "+" : "",
      ]},
      io_address:         "0x%02x",
      lower_io_address:   "0x%02x",
      bit_number:         "%d",
    }

    attr_reader :mnemonic
    attr_reader :arg_types
    attr_reader :sreg_flags
    attr_reader :opcode_proc

    def initialize(mnemonic, arg_types, sreg_flags, opcode_proc)
      @mnemonic = mnemonic
      @arg_types = arg_types
      @sreg_flags = sreg_flags
      @opcode_proc = opcode_proc
      arg_types.each do |arg_type|
        raise "Unknown Opcode argument type: #{arg_type}" unless OPCODE_ARGUMENT_TYPES[arg_type]
      end
    end

    def validate_arg(cpu, arg, arg_number)
      case arg_types[arg_number]
      when :register
        return RegisterExpected unless arg.is_a?(AVR::Register)
      when :word_register
        return WordRegisterExpected unless arg.is_a?(AVR::RegisterPair)
      when :byte
        return ByteConstantExpected unless arg.is_a?(Fixnum)
        return ConstantOutOfRange unless arg >= 0x00 and arg <= 0xff
      when :word
        return WordConstantExpected unless arg.is_a?(Fixnum)
        return ConstantOutOfRange unless arg >= 0x0000 and arg <= 0xffff
      when :absolute_pc
        return AbsolutePcExpected unless arg.is_a?(Fixnum)
        return ConstantOutOfRange unless arg >= 0 and arg <= 2**22-1
      when :near_relative_pc
        return NearRelativePcExpected unless arg.is_a?(Fixnum)
        return ConstantOutOfRange unless arg >= -64 and arg <= 63
      when :far_relative_pc
        return FarRelativePcExpected unless arg.is_a?(Fixnum)
        return ConstantOutOfRange unless arg >= -2048 and arg <= 2047
      when :io_address
        return IoAddressExpected unless arg.is_a?(Fixnum)
        return ConstantOutOfRange unless arg >= 0 and arg <= 63
      when :lower_io_address
        return IoAddressExpected unless arg.is_a?(Fixnum)
        return ConstantOutOfRange unless arg >= 0 and arg <= 31
      when :bit_number
        return BitNumberExpected unless arg.is_a?(Fixnum)
        return ConstantOutOfRange unless arg >= 0 and arg <= 7
      when :sreg_flag
        return StatusRegisterBitExpected unless arg.is_a?(Symbol)
        return StatusRegisterBitExpected unless AVR::SREG::STATUS_BITS.include?(arg)
      end
    end

    def validate(cpu, args)
      raise IncorrectArgumentCount unless args.size == arg_types.size

      args.each_with_index do |arg, i|
        arg_exception = validate_arg(cpu, arg, i)
        if arg_exception
          raise arg_exception.new("Argument #{i} (#{arg}) invalid for #{arg_types[i]}")
        end
      end

      true
    end

    def format_args(args)
      formatted_args = []
      args.each_with_index do |arg, i|
        arg_formatter = OPCODE_ARGUMENT_TYPES[arg_types[i]]
        case arg_formatter
        when String
          formatted_args << (arg_formatter % arg)
        when Proc
          formatted_args << arg_formatter.call(arg)
        else
          raise "Unknown argument formatter (#{arg_formatter.class}) for #{arg}"
        end
      end
      formatted_args
    end

    def inspect
      "#<#{self.class.name} #{mnemonic} #{arg_types}>"
    end

    def execute(cpu, memory, offset, args)
      opcode_proc.call(cpu, memory, offset, args)
    end

    OPCODES = {}

    def self.opcode(mnemonic, arg_types=[], sreg_flags=[], &block)
      raise "No block given" unless block_given?
      OPCODES[mnemonic] = Opcode.new(mnemonic, arg_types, sreg_flags, block.to_proc)
    end
  end
end

require "avr/opcode/nop"
require "avr/opcode/register"
require "avr/opcode/compare"
require "avr/opcode/data/stack"
require "avr/opcode/data/immediate"
require "avr/opcode/data/program"
require "avr/opcode/data/sram"
require "avr/opcode/branch/unconditional"
require "avr/opcode/branch/conditional"
require "avr/opcode/math/addition"
require "avr/opcode/math/subtraction"
require "avr/opcode/math/bitwise"
require "avr/opcode/io/bit"
require "avr/opcode/io/in_out"
