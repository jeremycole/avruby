module AVR
  class Opcode
    decode("1001 0100 0000 1100", :jmp) do |cpu, opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:jmp, k)
    end

    decode("1001 010k kkkk 110k", :jmp) do |cpu, opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:jmp, operands[:k] << 16 | k)
    end

    opcode(:jmp, [:absolute_pc]) do |cpu, memory, args|
      cpu.next_pc = args[0]
    end

    decode("1100 kkkk kkkk kkkk", :rjmp) do |cpu, opcode_definition, operands|
      cpu.instruction(:rjmp, operands[:k])
    end

    opcode(:rjmp, [:far_relative_pc]) do |cpu, memory, args|
      cpu.next_pc = cpu.pc + args[0] + 1
    end

    decode("1001 0100 0000 1001", :ijmp) do |cpu, opcode_definition, operands|
      cpu.instruction(:ijmp)
    end

    opcode(:ijmp) do |cpu, memory, args|
      cpu.next_pc = cpu.Z.value
    end

    decode("1001 0100 0000 1110", :call) do |cpu, opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:call, k)
    end

    decode("1001 010k kkkk 111k", :call) do |cpu, opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:call, operands[:k] << 16 | k)
    end

    opcode(:call, [:absolute_pc]) do |cpu, memory, args|
      stack_push_word(cpu, cpu.pc + 2)
      cpu.next_pc = args[0]
    end

    decode("1101 kkkk kkkk kkkk", :rcall) do |cpu, opcode_definition, operands|
      cpu.instruction(:rcall, operands[:k])
    end

    opcode(:rcall, [:far_relative_pc]) do |cpu, memory, args|
      stack_push_word(cpu, cpu.pc + 1)
      cpu.next_pc = cpu.pc + args[0] + 1
    end

    decode("1001 0101 0000 1001", :icall) do |cpu, opcode_definition, operands|
      cpu.instruction(:icall)
    end

    opcode(:icall) do |cpu, memory, args|
      stack_push_word(cpu, cpu.pc + 1)
      cpu.next_pc = cpu.Z.value
    end
  end
end