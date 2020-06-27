# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode('1001 0101 0000 1000', :ret) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:ret)
    end

    opcode(:ret) do |cpu, _memory, _args|
      cpu.next_pc = stack_pop_word(cpu)
    end

    decode('1001 0101 0001 1000', :reti) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:reti)
    end

    opcode(:reti, %i[], %i[I]) do |cpu, _memory, _args|
      cpu.sreg.I = true
      cpu.next_pc = stack_pop_word(cpu)
    end
  end
end
