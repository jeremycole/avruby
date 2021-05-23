# typed: strict
# frozen_string_literal: true

module AVR
  extend T::Sig

  class Opcode
    extend T::Sig

    class OpcodeException < RuntimeError; end

    class OpcodeNotImplementedError < OpcodeException; end

    class IncorrectArgumentCount < OpcodeException; end

    class IncorrectArgumentOptionality < OpcodeException; end

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

    class OpcodeArgumentDefinition
      attr_reader :type_name
      attr_reader :formatter

      def initialize(type_name, formatter = proc { |arg| Kernel.format("%s", arg) })
        @required = true
        @type_name = type_name
        @formatter = formatter.is_a?(String) ? proc { |arg| Kernel.format(formatter, arg) } : formatter
      end

      def format(arg)
        formatter.call(arg)
      end

      def optional
        @required = false
        self
      end

      def required?
        @required
      end

      def optional?
        !required?
      end
    end

    module Arg
      def self.register
        OpcodeArgumentDefinition.new(:register)
      end

      def self.register_pair
        OpcodeArgumentDefinition.new(:register_pair)
      end

      def self.sreg_flag
        OpcodeArgumentDefinition.new(:sreg_flag)
      end

      def self.near_relative_pc
        OpcodeArgumentDefinition.new(:near_relative_pc, proc { |arg| format(".%+d", 2 * arg.value) })
      end

      def self.far_relative_pc
        OpcodeArgumentDefinition.new(:far_relative_pc, proc { |arg| format(".%+d", 2 * arg.value) })
      end

      def self.absolute_pc
        OpcodeArgumentDefinition.new(:absolute_pc, proc { |arg| format("0x%04x", 2 * arg.value) })
      end

      def self.byte
        OpcodeArgumentDefinition.new(:byte, "0x%02x")
      end

      def self.word
        OpcodeArgumentDefinition.new(:word, "0x%04x")
      end

      def self.word_register
        OpcodeArgumentDefinition.new(:word_register)
      end

      def self.modifying_word_register
        OpcodeArgumentDefinition.new(:modifying_word_register)
      end

      def self.displaced_word_register
        OpcodeArgumentDefinition.new(:displaced_word_register, proc { |arg|
          format("%s%+d", arg.register.name, arg.displacement)
        })
      end

      def self.register_with_bit_number
        OpcodeArgumentDefinition.new(:register_with_bit_number)
      end

      def self.io_address
        OpcodeArgumentDefinition.new(:io_address, "0x%02x")
      end

      def self.lower_io_address
        OpcodeArgumentDefinition.new(:lower_io_address, "0x%02x")
      end

      def self.bit_number
        OpcodeArgumentDefinition.new(:bit_number, "%d")
      end
    end

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
      # Ensure we don't have required arguments after optional ones...
      if arg_types.map(&:required?).slice_when { |a, b| a != b }.flat_map(&:uniq).each_cons(2).include?([false, true])
        raise IncorrectArgumentOptionality
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

    def required_arg_count
      arg_types.select(&:required?).size..arg_types.size
    end

    sig { params(args: T::Array[T.untyped]).returns(T::Boolean) }
    def validate(args)
      raise IncorrectArgumentCount unless required_arg_count.include?(args.size)

      args.each_with_index do |arg, i|
        arg_exception = validate_arg(arg, i)

        raise arg_exception, "Argument #{i} (#{arg}) invalid for #{arg_types[i]}" if arg_exception
      end

      true
    end

    sig { params(args: T::Array[T.untyped]).returns(T::Array[String]) }
    def format_args(args)
      args.each_with_index.map { |arg, i| arg_types[i].format(arg) }
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
      raise "No block given" unless block_given?

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
