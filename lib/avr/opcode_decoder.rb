# frozen_string_literal: true

module AVR
  class OpcodeDecoder
    class OpcodeDefinition
      attr_reader :pattern
      attr_reader :mnemonic
      attr_reader :options
      attr_reader :parse_proc

      def initialize(pattern, mnemonic, parse_proc)
        @pattern = pattern.gsub(/[^01a-zA-Z]/, '')
        @mnemonic = mnemonic
        @options = options
        @parse_proc = parse_proc

        raise "Incorrect pattern length for #{pattern}" unless @pattern.size == 16
      end

      def operand_pattern
        @operand_pattern ||= pattern.gsub(/[01]/, '_')
      end

      def match_value
        @match_value ||= pattern.gsub(/[^01]/, '0').to_i(2)
      end

      def match_mask
        @match_mask ||= pattern.gsub(/[01]/, '1').gsub(/[^01]/, '0').to_i(2)
      end

      def match?(word)
        word & match_mask == match_value
      end

      def extract_operands(word)
        operands = Hash.new(0)
        mask = 0x10000
        pattern.split('').each do |operand|
          mask >>= 1
          next if %w[0 1].include?(operand)

          operands[operand.to_sym] <<= 1
          operands[operand.to_sym] |= 1 if (word & mask) != 0
        end
        operands
      end

      def parse(cpu, opcode_definition, operands)
        parse_proc.call(cpu, opcode_definition, operands)
      end
    end

    class OperandParser
      attr_reader :pattern
      attr_reader :parse_proc

      def initialize(pattern, parse_proc)
        @pattern = pattern.gsub(/[^01a-zA-Z_]/, '')
        @parse_proc = parse_proc
      end

      def parse(cpu, operands)
        parse_proc.call(cpu, operands)
      end
    end

    class DecodedOpcode
      attr_reader :opcode_definition
      attr_reader :operands

      def initialize(opcode_definition, operands)
        @opcode_definition = opcode_definition
        @operands = operands
      end

      def prepare_operands(cpu)
        parser = OpcodeDecoder.operand_parsers[opcode_definition.operand_pattern]
        parser&.parse(cpu, operands) || operands
      end
    end

    @opcode_definitions = []
    @opcode_match_masks = {}
    @operand_parsers = {}

    class << self
      attr_reader :opcode_definitions
      attr_reader :opcode_match_masks
      attr_reader :operand_parsers
    end

    def self.add_opcode_definition(opcode_definition)
      opcode_definitions << opcode_definition
      opcode_match_masks[opcode_definition.match_mask] ||= {}
      opcode_match_masks[opcode_definition.match_mask][opcode_definition.match_value] = opcode_definition
    end

    def self.add_operand_parser(operand_parser)
      operand_parsers[operand_parser.pattern] = operand_parser
    end

    attr_reader :cache

    def initialize
      @cache = {}
    end

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

    def print_cache
      puts "Opcode decoder cache (#{cache.size} opcodes cached):"
      cache.sort.each do |word, decoded_opcode|
        puts "  %04x = %17s = %-6s (%s)" % [
          word,
          word.to_s(2).rjust(16, '0').split('').each_slice(8).map(&:join).join(' '),
          decoded_opcode.opcode_definition.mnemonic,
          decoded_opcode.operands.map { |k, v| '%s = %5d' % [k, v] }.join(', ')
        ]
      end
      nil
    end
  end
end
