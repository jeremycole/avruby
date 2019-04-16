module AVR
  class Opcode
    decode("1001 0101 0000 1000", :ret) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :ret)
    end

    opcode(:ret) do |cpu, memory, offset, args|
      cpu.next_pc = stack_pop_word(cpu)
    end

    decode("1001 0101 0001 1000", :reti) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :reti)
    end

    opcode(:reti, [], [:I]) do |cpu, memory, offset, args|
      cpu.sreg.I = true
      cpu.next_pc = stack_pop_word(cpu)
    end
  end
end