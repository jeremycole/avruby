# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    parse_operands("____ ____ KKKK ____") do |_cpu, operands|
      {
        k: operands.fetch(:K),
      }
    end

    decode("1001 0100 KKKK 1011", :des) do |cpu, _opcode_definition, operands|
      cpu.instruction(:des, operands.fetch(:k))
    end

    opcode(:des, [Arg.byte]) do |_cpu, _memory, _args|
      raise OpcodeNotImplementedError, "des"
    end
  end
end
