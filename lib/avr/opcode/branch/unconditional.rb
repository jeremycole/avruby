# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode('1001 0100 0000 1100', :jmp) do |cpu, _opcode_definition, _operands|
      k = cpu.fetch
      cpu.instruction(:jmp, k)
    end

    decode('1001 010k kkkk 110k', :jmp) do |cpu, _opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:jmp, operands[:k] << 16 | k)
    end

    opcode(:jmp, %i[absolute_pc]) do |cpu, _memory, args|
      cpu.next_pc = args[0]
    end

    decode('1001 0100 0000 1110', :call) do |cpu, _opcode_definition, _operands|
      k = cpu.fetch
      cpu.instruction(:call, k)
    end

    decode('1001 010k kkkk 111k', :call) do |cpu, _opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:call, operands[:k] << 16 | k)
    end

    opcode(:call, %i[absolute_pc]) do |cpu, _memory, args|
      stack_push_word(cpu, cpu.pc + 2)
      cpu.next_pc = args[0]
    end

    # rcall rjmp
    parse_operands('____ kkkk kkkk kkkk') do |_cpu, operands|
      { k: twos_complement(operands[:k], 12) }
    end

    decode('1100 kkkk kkkk kkkk', :rjmp) do |cpu, _opcode_definition, operands|
      cpu.instruction(:rjmp, operands[:k])
    end

    opcode(:rjmp, %i[far_relative_pc]) do |cpu, _memory, args|
      cpu.next_pc = cpu.pc + args[0] + 1
    end

    decode('1101 kkkk kkkk kkkk', :rcall) do |cpu, _opcode_definition, operands|
      cpu.instruction(:rcall, operands[:k])
    end

    opcode(:rcall, %i[far_relative_pc]) do |cpu, _memory, args|
      stack_push_word(cpu, cpu.pc + 1)
      cpu.next_pc = cpu.pc + args[0] + 1
    end

    decode('1001 0100 0000 1001', :ijmp) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:ijmp)
    end

    opcode(:ijmp) do |cpu, _memory, _args|
      cpu.next_pc = cpu.Z.value
    end

    decode('1001 0101 0000 1001', :icall) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:icall)
    end

    opcode(:icall) do |cpu, _memory, _args|
      stack_push_word(cpu, cpu.pc + 1)
      cpu.next_pc = cpu.Z.value
    end
  end
end
