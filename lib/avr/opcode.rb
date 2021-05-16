# typed: strict
# frozen_string_literal: true

module AVR
  extend T::Sig

  class Opcode
    extend T::Sig

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
    OPCODE_ARGUMENT_TYPES = T.let(
      {
        sreg_flag:          '%s',
        near_relative_pc:   proc { |arg| '.%+d' % [2 * arg.value] },
        far_relative_pc:    proc { |arg| '.%+d' % [2 * arg.value] },
        absolute_pc:        proc { |arg| '0x%04x' % [2 * arg.value] },
        byte:               '0x%02x',
        word:               '0x%04x',
        register:           '%s',
        register_pair:      '%s',
        word_register:      '%s',
        modifying_word_register: '%s',
        displaced_word_register: proc { |arg|
          '%s%+d' % [arg.register.name, arg.displacement]
        },
        register_with_bit_number: '%s',
        io_address:         '0x%02x',
        lower_io_address:   '0x%02x',
        bit_number:         '%d',
      }.freeze,
      T::Hash[Symbol, T.any(String, T.proc.params(arg: T::Array[Integer]).returns(String))]
    )
    # rubocop:enable Layout/HashAlignment

    sig { returns(Symbol) }
    attr_reader :mnemonic

    sig { returns(T::Array[Symbol]) }
    attr_reader :arg_types

    sig { returns(T::Array[Symbol]) }
    attr_reader :sreg_flags

    ProcType = T.type_alias do
      T.proc.params(
        cpu: CPU,
        memory: T.nilable(Memory),
        args: Argument::ArrayType
      ).void
    end

    sig { returns(Opcode::ProcType) }
    attr_reader :opcode_proc

    ExtractedOperandHashType = T.type_alias { T::Hash[Symbol, Integer] }
    OperandValueHashType = T.type_alias { T::Hash[Symbol, Argument::ValueType] }

    sig do
      params(
        mnemonic: Symbol,
        arg_types: T::Array[Symbol],
        sreg_flags: T::Array[Symbol],
        opcode_proc: Opcode::ProcType
      ).void
    end
    def initialize(mnemonic, arg_types, sreg_flags, opcode_proc)
      @mnemonic = mnemonic
      @arg_types = arg_types
      @sreg_flags = sreg_flags
      @opcode_proc = opcode_proc
      arg_types.each do |arg_type|
        raise "Unknown Opcode argument type: #{arg_type}" unless OPCODE_ARGUMENT_TYPES[arg_type]
      end
    end

    sig { params(arg: T.untyped, arg_number: Integer).returns(T.nilable(T.class_of(OpcodeException))) }
    def validate_arg(arg, arg_number)
      case arg_types[arg_number]
      when :register
        return RegisterExpected unless arg.is_a?(Register)
      when :word_register
        return WordRegisterExpected unless arg.is_a?(RegisterPair)
      when :byte
        return ByteConstantExpected unless arg.is_a?(Value)
        return ConstantOutOfRange unless arg.value >= 0x00 && arg.value <= 0xff
      when :word
        return WordConstantExpected unless arg.is_a?(Value)
        return ConstantOutOfRange unless arg.value >= 0x0000 && arg.value <= 0xffff
      when :absolute_pc
        return AbsolutePcExpected unless arg.is_a?(Value)
        return ConstantOutOfRange unless arg.value >= 0 && arg.value <= (2**22).to_i - 1
      when :near_relative_pc
        return NearRelativePcExpected unless arg.is_a?(Value)
        return ConstantOutOfRange unless arg.value >= -64 && arg.value <= 63
      when :far_relative_pc
        return FarRelativePcExpected unless arg.is_a?(Value)
        return ConstantOutOfRange unless arg.value >= -2048 && arg.value <= 2047
      when :io_address
        return IoAddressExpected unless arg.is_a?(Value)
        return ConstantOutOfRange unless arg.value >= 0 && arg.value <= 63
      when :lower_io_address
        return IoAddressExpected unless arg.is_a?(Value)
        return ConstantOutOfRange unless arg.value >= 0 && arg.value <= 31
      when :register_with_bit_number
        return RegisterExpected unless arg.register.is_a?(Register)
        return BitNumberExpected unless arg.bit_number.is_a?(Integer)
        return ConstantOutOfRange unless arg.bit_number >= 0 && arg.bit_number <= 7
      when :sreg_flag
        return StatusRegisterBitExpected unless arg.is_a?(Value)
        return StatusRegisterBitExpected unless arg.value == 0 || arg.value == 1
      end
    end

    sig { params(args: T::Array[T.untyped]).returns(T::Boolean) }
    def validate(args)
      raise IncorrectArgumentCount unless args.size == arg_types.size

      args.each_with_index do |arg, i|
        arg_exception = validate_arg(arg, i)

        raise arg_exception, "Argument #{i} (#{arg}) invalid for #{arg_types[i]}" if arg_exception
      end

      true
    end

    sig { params(args: T::Array[T.untyped]).returns(T::Array[String]) }
    def format_args(args)
      formatted_args = []
      args.each_with_index do |arg, i|
        arg_formatter = OPCODE_ARGUMENT_TYPES[T.must(arg_types[i])]
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

    sig { returns(String) }
    def inspect
      "#<#{self.class.name} #{mnemonic} #{arg_types}>"
    end

    sig { params(cpu: CPU, memory: T.nilable(Memory), args: T::Array[T.untyped]).void }
    def execute(cpu, memory, args)
      opcode_proc.call(cpu, memory, args)
    end

    @opcodes = T.let({}, T::Hash[Symbol, Opcode])

    class << self
      extend T::Sig
      sig { returns(T::Hash[Symbol, Opcode]) }
      attr_reader :opcodes
    end

    sig { params(cpu: CPU, byte: Integer).returns(Integer) }
    def self.stack_push(cpu, byte)
      cpu.sram.memory.fetch(cpu.sp.value).value = byte
      cpu.sp.decrement
    end

    sig { params(cpu: CPU, word: Integer).returns(Integer) }
    def self.stack_push_word(cpu, word)
      stack_push(cpu, (word & 0xff00) >> 8)
      stack_push(cpu, (word & 0x00ff))
    end

    sig { params(cpu: CPU).returns(Integer) }
    def self.stack_pop(cpu)
      cpu.sp.increment
      cpu.sram.memory.fetch(cpu.sp.value).value
    end

    sig { params(cpu: CPU).returns(Integer) }
    def self.stack_pop_word(cpu)
      stack_pop(cpu) | (stack_pop(cpu) << 8)
    end

    sig do
      params(
        mnemonic: Symbol,
        arg_types: T::Array[Symbol],
        sreg_flags: T::Array[Symbol],
        block: T.nilable(Opcode::ProcType)
      ).returns(Opcode)
    end
    def self.opcode(mnemonic, arg_types = [], sreg_flags = [], &block)
      raise 'No block given' unless block_given?

      opcodes[mnemonic] = Opcode.new(mnemonic, arg_types, sreg_flags, block.to_proc)
    end

    sig { params(pattern: String, mnemonic: Symbol, block: OpcodeDecoder::OpcodeDefinition::ProcType).void }
    def self.decode(pattern, mnemonic, &block)
      OpcodeDecoder.add_opcode_definition(
        OpcodeDecoder::OpcodeDefinition.new(pattern, mnemonic, block.to_proc)
      )
    end

    sig { params(pattern: String, block: T.untyped).void }
    def self.parse_operands(pattern, &block)
      OpcodeDecoder.add_operand_parser(OpcodeDecoder::OperandParser.new(pattern, block.to_proc))
    end
  end
end
