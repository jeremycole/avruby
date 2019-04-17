module AVR
  class Opcode
    decode("1001 0101 0000 1000", :ret) do |cpu, opcode_definition, operands|
      cpu.instruction(:ret)
    end

    opcode(:ret) do |cpu, memory, args|
      cpu.next_pc = stack_pop_word(cpu)
    end

    decode("1001 0101 0001 1000", :reti) do |cpu, opcode_definition, operands|
      cpu.instruction(:reti)
    end

    opcode(:reti, [], [:I]) do |cpu, memory, args|
      cpu.sreg.I = true
      cpu.next_pc = stack_pop_word(cpu)
    end
  end
end