# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode("1001 001r rrrr 1111", :push) do |cpu, _opcode_definition, operands|
      cpu.instruction(:push, operands.fetch(:Rr))
    end

    opcode(:push, [:register]) do |cpu, _memory, args|
      stack_push(cpu, args.fetch(0).value)
    end

    decode("1001 000d dddd 1111", :pop) do |cpu, _opcode_definition, operands|
      cpu.instruction(:pop, operands.fetch(:Rd))
    end

    opcode(:pop, [:register]) do |cpu, _memory, args|
      args.fetch(0).value = stack_pop(cpu)
    end
  end
end
