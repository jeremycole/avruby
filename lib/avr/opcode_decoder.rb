# typed: strict
# frozen_string_literal: true

module AVR
  class OpcodeDecoder
    extend T::Sig

    class OpcodeDefinition
      extend T::Sig

      ProcType = T.type_alias do
        T.proc.params(
          cpu: CPU,
          opcode_definition: OpcodeDefinition,
          operands: Opcode::OperandValueHashType
        ).returns(Instruction)
      end

      sig { returns(String) }
      attr_reader :pattern

      sig { returns(Symbol) }
      attr_reader :mnemonic

      sig { returns(ProcType) }
      attr_reader :parse_proc

      sig { params(pattern: String, mnemonic: Symbol, parse_proc: ProcType).void }
      def initialize(pattern, mnemonic, parse_proc)
        @pattern = T.let(pattern.gsub(/[^01a-zA-Z]/, ""), String)
        raise "Incorrect pattern length for #{pattern}" unless @pattern.size == 16

        @mnemonic = mnemonic
        @parse_proc = parse_proc

        @operand_pattern = T.let(nil, T.nilable(String))
        @match_value = T.let(nil, T.nilable(Integer))
        @match_mask = T.let(nil, T.nilable(Integer))
      end

      sig { returns(String) }
      def operand_pattern
        @operand_pattern ||= pattern.gsub(/[01]/, "_")
      end

      sig { returns(Integer) }
      def match_value
        @match_value ||= pattern.gsub(/[^01]/, "0").to_i(2)
      end

      sig { returns(Integer) }
      def match_mask
        @match_mask ||= pattern.gsub(/[01]/, "1").gsub(/[^01]/, "0").to_i(2)
      end

      sig { params(word: Integer).returns(T::Boolean) }
      def match?(word)
        word & match_mask == match_value
      end

      sig { params(word: Integer).returns(Argument::NamedValueType) }
      def extract_operands(word)
        operands = Hash.new(0)
        mask = 0x10000
        pattern.split("").each do |operand|
          mask >>= 1
          next if ["0", "1"].include?(operand)

          operands[operand.to_sym] <<= 1
          operands[operand.to_sym] |= 1 if (word & mask) != 0
        end
        operands.each_with_object({}) { |(k, v), h| h[k] = Value.new(v) }
      end

      sig do
        params(
          cpu: CPU,
          opcode_definition: OpcodeDefinition,
          operands: Argument::NamedValueType
        ).returns(Instruction)
      end
      def parse(cpu, opcode_definition, operands)
        parse_proc.call(cpu, opcode_definition, operands)
      end
    end

    class OperandParser
      extend T::Sig

      sig { returns(String) }
      attr_reader :pattern

      ProcType = T.type_alias do
        T.proc.params(cpu: CPU, operands: Opcode::OperandValueHashType).returns(Opcode::OperandValueHashType)
      end

      sig { returns(OperandParser::ProcType) }
      attr_reader :parse_proc

      sig { params(pattern: String, parse_proc: OperandParser::ProcType).void }
      def initialize(pattern, parse_proc)
        @pattern = T.let(pattern.gsub(/[^01a-zA-Z_]/, ""), String)
        @parse_proc = T.let(parse_proc, OperandParser::ProcType)
      end

      sig { params(cpu: CPU, operands: Opcode::OperandValueHashType).returns(Opcode::OperandValueHashType) }
      def parse(cpu, operands)
        parse_proc.call(cpu, operands)
      end
    end

    class DecodedOpcode
      extend T::Sig

      sig { returns(OpcodeDefinition) }
      attr_reader :opcode_definition

      sig { returns(Opcode::OperandValueHashType) }
      attr_reader :operands

      sig { params(opcode_definition: OpcodeDefinition, operands: Opcode::OperandValueHashType).void }
      def initialize(opcode_definition, operands)
        @opcode_definition = opcode_definition
        @operands = operands
      end

      sig { params(cpu: CPU).returns(Opcode::OperandValueHashType) }
      def prepare_operands(cpu)
        parser = OpcodeDecoder.operand_parsers[opcode_definition.operand_pattern]
        parser&.parse(cpu, operands) || operands
      end
    end

    @opcode_definitions = T.let([], T::Array[OpcodeDefinition])
    @opcode_match_masks = T.let({}, T::Hash[Integer, T::Hash[Integer, OpcodeDefinition]])
    @operand_parsers = T.let({}, T::Hash[String, OpcodeDecoder::OperandParser])

    class << self
      extend T::Sig

      sig { returns(T::Array[OpcodeDefinition]) }
      attr_reader :opcode_definitions

      sig { returns(T::Hash[Integer, T::Hash[Integer, OpcodeDefinition]]) }
      attr_reader :opcode_match_masks

      sig { returns(T::Hash[String, OpcodeDecoder::OperandParser]) }
      attr_reader :operand_parsers
    end

    sig { params(opcode_definition: OpcodeDefinition).void }
    def self.add_opcode_definition(opcode_definition)
      opcode_definitions << opcode_definition
      opcode_match_masks[opcode_definition.match_mask] ||= {}
      opcode_match_masks.fetch(opcode_definition.match_mask)[opcode_definition.match_value] = opcode_definition
    end

    sig { params(operand_parser: OperandParser).void }
    def self.add_operand_parser(operand_parser)
      operand_parsers[operand_parser.pattern] = operand_parser
    end

    sig { returns(T::Hash[Integer, DecodedOpcode]) }
    attr_reader :cache

    sig { void }
    def initialize
      @cache = T.let({}, T::Hash[Integer, DecodedOpcode])
    end

    sig { params(word: Integer).returns(T.nilable(DecodedOpcode)) }
    def decode(word)
      cached_decoded_opcode = cache[word]
      return cached_decoded_opcode if cached_decoded_opcode

      OpcodeDecoder.opcode_match_masks.each do |mask, values|
        opcode_definition = values[word & mask]
        next unless opcode_definition

        operands = opcode_definition.extract_operands(word)
        decoded_opcode = DecodedOpcode.new(opcode_definition, operands)
        cache[word] = decoded_opcode
        return decoded_opcode
      end
      nil
    end

    sig { void }
    def print_cache
      puts "Opcode decoder cache (#{cache.size} opcodes cached):"
      cache.sort.each do |word, decoded_opcode|
        code = word.to_s(2).rjust(16, "0").split("").each_slice(8).map(&:join).join(" ")
        mnemonic = decoded_opcode.opcode_definition.mnemonic
        operands = decoded_opcode.operands.map { |k, v| format("%s = %5d", k, v) }.join(", ")
        puts format("  %04x = %17s = %-6s (%s)", word, code, mnemonic, operands)
      end
      nil
    end
  end
end
