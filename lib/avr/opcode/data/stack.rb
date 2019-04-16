module AVR
  class Opcode
    decode("1001 001r rrrr 1111", :push) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :push, operands[:Rr])
    end

    opcode(:push, [:register]) do |cpu, memory, offset, args|
      stack_push(cpu, args[0].value)
    end

    decode("1001 000d dddd 1111", :pop) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :pop, operands[:Rd])
    end

    opcode(:pop, [:register]) do |cpu, memory, offset, args|
      args[0].value = stack_pop(cpu)
    end
  end
end