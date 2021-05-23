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
      extend T::Sig

      FormatterProc = T.type_alias do
        T.proc.params(arg: T.untyped).returns(String)
      end

      ValidatorProc = T.type_alias do
        T.proc.params(arg: T.untyped).returns(T.nilable(T.class_of(OpcodeException)))
      end

      sig { returns(Symbol) }
      attr_reader :type_name

      sig { params(type_name: Symbol, format: String).void }
      def initialize(type_name, format: "%s")
        @required = T.let(true, T::Boolean)
        @type_name = type_name
        @formatter = T.let(proc { |arg| Kernel.format(format, arg) }, FormatterProc)
        @validators = T.let([], T::Array[ValidatorProc])
      end

      sig { params(block: FormatterProc).returns(OpcodeArgumentDefinition) }
      def formatter(&block)
        @formatter = block

        self
      end

      sig { params(arg: Argument::ValueType).returns(String) }
      def format(arg)
        @formatter.call(arg)
      end

      sig { params(block: ValidatorProc).returns(OpcodeArgumentDefinition) }
      def validator(&block)
        @validators << block

        self
      end

      sig { params(arg: T.untyped).returns(T.nilable(T::Array[T.class_of(AVR::Opcode::OpcodeException)])) }
      def validate(arg)
        @validators.map { |validator| validator.call(arg) }.compact
      end

      sig { returns(OpcodeArgumentDefinition) }
      def optional
        @required = false

        self
      end

      sig { returns(T::Boolean) }
      def required?
        @required
      end

      sig { returns(T::Boolean) }
      def optional?
        !required?
      end
    end

    module Arg
      extend T::Sig

      sig { returns(OpcodeArgumentDefinition) }
      def self.register
        OpcodeArgumentDefinition
          .new(:register)
          .validator { |arg| RegisterExpected unless arg.is_a?(Register) }
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.register_pair
        OpcodeArgumentDefinition
          .new(:register_pair)
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.sreg_flag
        OpcodeArgumentDefinition
          .new(:sreg_flag)
          .validator { |arg| StatusRegisterBitExpected unless arg.is_a?(Value) }
          .validator { |arg| StatusRegisterBitExpected unless arg.value == 0 || arg.value == 1 }
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.near_relative_pc
        OpcodeArgumentDefinition
          .new(:near_relative_pc)
          .formatter { |arg| format(".%+d", 2 * arg.value) }
          .validator { |arg| NearRelativePcExpected unless arg.is_a?(Value) }
          .validator { |arg| ConstantOutOfRange unless arg.value >= -64 && arg.value <= 63 }
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.far_relative_pc
        OpcodeArgumentDefinition
          .new(:far_relative_pc)
          .formatter { |arg| format(".%+d", 2 * arg.value) }
          .validator { |arg| FarRelativePcExpected unless arg.is_a?(Value) }
          .validator { |arg| ConstantOutOfRange unless arg.value >= -2048 && arg.value <= 2047 }
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.absolute_pc
        OpcodeArgumentDefinition
          .new(:absolute_pc)
          .formatter { |arg| format("0x%04x", 2 * arg.value) }
          .validator { |arg| AbsolutePcExpected unless arg.is_a?(Value) }
          .validator { |arg| ConstantOutOfRange unless arg.value >= 0 && arg.value <= (2**22).to_i - 1 }
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.byte
        OpcodeArgumentDefinition
          .new(:byte, format: "0x%02x")
          .validator { |arg| ByteConstantExpected unless arg.is_a?(Value) }
          .validator { |arg| ConstantOutOfRange unless arg.value >= 0x00 && arg.value <= 0xff }
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.word
        OpcodeArgumentDefinition
          .new(:word, format: "0x%04x")
          .validator { |arg| WordConstantExpected unless arg.is_a?(Value) }
          .validator { |arg| ConstantOutOfRange unless arg.value >= 0x0000 && arg.value <= 0xffff }
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.word_register
        OpcodeArgumentDefinition
          .new(:word_register)
          .validator { |arg| WordRegisterExpected unless arg.is_a?(RegisterPair) }
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.modifying_word_register
        OpcodeArgumentDefinition
          .new(:modifying_word_register)
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.displaced_word_register
        OpcodeArgumentDefinition
          .new(:displaced_word_register)
          .formatter { |arg| format("%s%+d", arg.register.name, arg.displacement) }
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.register_with_bit_number
        OpcodeArgumentDefinition
          .new(:register_with_bit_number)
          .validator { |arg| RegisterExpected unless arg.register.is_a?(Register) }
          .validator { |arg| BitNumberExpected unless arg.bit_number.is_a?(Integer) }
          .validator { |arg| ConstantOutOfRange unless arg.bit_number >= 0 && arg.bit_number <= 7 }
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.io_address
        OpcodeArgumentDefinition
          .new(:io_address, format: "0x%02x")
          .validator { |arg| IoAddressExpected unless arg.is_a?(Value) }
          .validator { |arg| ConstantOutOfRange unless arg.value >= 0 && arg.value <= 63 }
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.lower_io_address
        OpcodeArgumentDefinition
          .new(:lower_io_address, format: "0x%02x")
          .validator { |arg| IoAddressExpected unless arg.is_a?(Value) }
          .validator { |arg| ConstantOutOfRange unless arg.value >= 0 && arg.value <= 31 }
      end

      sig { returns(OpcodeArgumentDefinition) }
      def self.bit_number
        OpcodeArgumentDefinition
          .new(:bit_number, format: "%d")
      end
    end

    sig { returns(Symbol) }
    attr_reader :mnemonic

    sig { returns(T::Array[OpcodeArgumentDefinition]) }
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
        arg_types: T::Array[OpcodeArgumentDefinition],
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

    sig { returns(T::Range[Integer]) }
    def required_arg_count
      arg_types.select(&:required?).size..arg_types.size
    end

    sig { params(args: T::Array[T.untyped]).returns(T::Boolean) }
    def validate(args)
      raise IncorrectArgumentCount unless required_arg_count.include?(args.size)

      args.each_with_index do |arg, i|
        T.must(arg_types[i]).validate(arg)&.each do |arg_exception|
          raise arg_exception, "Argument #{i} (#{arg}) invalid for #{T.must(arg_types[i]).type_name}"
        end
      end

      true
    end

    sig { params(args: T::Array[T.untyped]).returns(T::Array[String]) }
    def format_args(args)
      args.each_with_index.map { |arg, i| T.must(arg_types[i]).format(arg) }
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
        arg_types: T::Array[OpcodeArgumentDefinition],
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
