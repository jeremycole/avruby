module AVR
  class Opcode
    opcode(:ret) do |cpu, memory, offset, args|
      cpu.next_pc = stack_pop_word(cpu)
    end

    opcode(:reti, [], [:I]) do |cpu, memory, offset, args|
      cpu.sreg.I = true
      cpu.next_pc = stack_pop_word(cpu)
    end
  end
end