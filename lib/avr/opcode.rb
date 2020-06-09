# frozen_string_literal: true

require 'avr/opcode_decoder'

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

    # rubocop:disable Layout/HashAlignment
    OPCODE_ARGUMENT_TYPES = {
      sreg_flag:          '%s',
      near_relative_pc:   proc { |arg| '.%+d' % [2 * arg] },
      far_relative_pc:    proc { |arg| '.%+d' % [2 * arg] },
      absolute_pc:        proc { |arg| '0x%04x' % [2 * arg] },
      byte:               '0x%02x',
      word:               '0x%04x',
      register:           '%s',
      register_pair:      proc { |arg| '%s:%s' % [arg[0], arg[1]] },
      word_register:      '%s',
      modifying_word_register: proc { |arg|
        if arg.is_a?(AVR::RegisterPair)
          '%s' % arg
        else
          '%s%s%s' % [
            arg[1] == :pre_decrement ? '-' : '',
            arg[0].to_s,
            arg[1] == :post_increment ? '+' : '',
          ]
        end
      },
      displaced_word_register: proc { |arg|
        '%s%+d' % [arg[0], arg[1]]
      },
      io_address:         '0x%02x',
      lower_io_address:   '0x%02x',
      bit_number:         '%d',
    }.freeze
    # rubocop:enable Layout/HashAlignment

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

    def validate_arg(arg, arg_number)
      case arg_types[arg_number]
      when :register
        return RegisterExpected unless arg.is_a?(AVR::Register)
      when :word_register
        return WordRegisterExpected unless arg.is_a?(AVR::RegisterPair)
      when :byte
        return ByteConstantExpected unless arg.is_a?(Integer)
        return ConstantOutOfRange unless arg >= 0x00 && arg <= 0xff
      when :word
        return WordConstantExpected unless arg.is_a?(Integer)
        return ConstantOutOfRange unless arg >= 0x0000 && arg <= 0xffff
      when :absolute_pc
        return AbsolutePcExpected unless arg.is_a?(Integer)
        return ConstantOutOfRange unless arg >= 0 && arg <= 2**22 - 1
      when :near_relative_pc
        return NearRelativePcExpected unless arg.is_a?(Integer)
        return ConstantOutOfRange unless arg >= -64 && arg <= 63
      when :far_relative_pc
        return FarRelativePcExpected unless arg.is_a?(Integer)
        return ConstantOutOfRange unless arg >= -2048 && arg <= 2047
      when :io_address
        return IoAddressExpected unless arg.is_a?(Integer)
        return ConstantOutOfRange unless arg >= 0 && arg <= 63
      when :lower_io_address
        return IoAddressExpected unless arg.is_a?(Integer)
        return ConstantOutOfRange unless arg >= 0 && arg <= 31
      when :bit_number
        return BitNumberExpected unless arg.is_a?(Integer)
        return ConstantOutOfRange unless arg >= 0 && arg <= 7
      when :sreg_flag
        return StatusRegisterBitExpected unless arg.is_a?(Symbol)
        return StatusRegisterBitExpected unless AVR::SREG::STATUS_BITS.include?(arg)
      end
    end

    def validate(args)
      raise IncorrectArgumentCount unless args.size == arg_types.size

      args.each_with_index do |arg, i|
        arg_exception = validate_arg(arg, i)

        raise arg_exception, "Argument #{i} (#{arg}) invalid for #{arg_types[i]}" if arg_exception
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

    def execute(cpu, memory, args)
      opcode_proc.call(cpu, memory, args)
    end

    @opcodes = {}

    class << self
      attr_reader :opcodes
    end

    def self.stack_push(cpu, byte)
      cpu.sram.memory[cpu.sp.value].value = byte
      cpu.sp.decrement
    end

    def self.stack_push_word(cpu, word)
      stack_push(cpu, (word & 0xff00) >> 8)
      stack_push(cpu, (word & 0x00ff))
    end

    def self.stack_pop(cpu)
      cpu.sp.increment
      cpu.sram.memory[cpu.sp.value].value
    end

    def self.stack_pop_word(cpu)
      stack_pop(cpu) | (stack_pop(cpu) << 8)
    end

    def self.opcode(mnemonic, arg_types = [], sreg_flags = [], &block)
      raise 'No block given' unless block_given?

      opcodes[mnemonic] = Opcode.new(mnemonic, arg_types, sreg_flags, block.to_proc)
    end

    def self.decode(pattern, mnemonic, &block)
      AVR::OpcodeDecoder.add_opcode_definition(
        AVR::OpcodeDecoder::OpcodeDefinition.new(pattern, mnemonic, block.to_proc)
      )
    end

    def self.parse_operands(pattern, &block)
      AVR::OpcodeDecoder.add_operand_parser(AVR::OpcodeDecoder::OperandParser.new(pattern, block.to_proc))
    end
  end
end
