module AVR
  class Opcode
    opcode(:jmp, [:absolute_pc]) do |cpu, memory, offset, args|
      cpu.next_pc = args[0]
    end

    opcode(:rjmp, [:far_relative_pc]) do |cpu, memory, offset, args|
      cpu.next_pc = cpu.pc + args[0] + 1
    end

    opcode(:call, [:absolute_pc]) do |cpu, memory, offset, args|
      stack_push_word(cpu, cpu.pc + 2)
      cpu.next_pc = args[0]
    end

    opcode(:rcall, [:far_relative_pc]) do |cpu, memory, offset, args|
      stack_push_word(cpu, cpu.pc + 1)
      cpu.next_pc = cpu.pc + args[0] + 1
    end
  end
end