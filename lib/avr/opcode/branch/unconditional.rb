module AVR
  class Opcode
    decode("1001 010k kkkk 110k", :jmp) do |cpu, offset, opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(offset, :jmp, operands[:k] << 16 | k)
    end

    opcode(:jmp, [:absolute_pc]) do |cpu, memory, offset, args|
      cpu.next_pc = args[0]
    end

    decode("1100 kkkk kkkk kkkk", :rjmp) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :rjmp, operands[:k])
    end

    opcode(:rjmp, [:far_relative_pc]) do |cpu, memory, offset, args|
      cpu.next_pc = cpu.pc + args[0] + 1
    end

    decode("1001 0100 0000 1001", :ijmp) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :ijmp)
    end

    opcode(:ijmp) do |cpu, memory, offset, args|
      cpu.next_pc = cpu.Z.value
    end

    decode("1001 010k kkkk 111k", :call) do |cpu, offset, opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(offset, :call, operands[:k] << 16 | k)
    end

    opcode(:call, [:absolute_pc]) do |cpu, memory, offset, args|
      stack_push_word(cpu, cpu.pc + 2)
      cpu.next_pc = args[0]
    end

    decode("1101 kkkk kkkk kkkk", :rcall) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :rcall, operands[:k])
    end

    opcode(:rcall, [:far_relative_pc]) do |cpu, memory, offset, args|
      stack_push_word(cpu, cpu.pc + 1)
      cpu.next_pc = cpu.pc + args[0] + 1
    end

    decode("1001 0101 0000 1001", :icall) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :icall)
    end

    opcode(:icall) do |cpu, memory, offset, args|
      stack_push_word(cpu, cpu.pc + 1)
      cpu.next_pc = cpu.Z.value
    end
  end
end