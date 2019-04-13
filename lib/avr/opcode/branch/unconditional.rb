module AVR
  class Opcode
    opcode(:jmp, [:pc]) do |cpu, memory, offset, args|
      cpu.pc = args[0]
    end

    opcode(:rjmp, [:relative_pc]) do |cpu, memory, offset, args|
      cpu.pc = cpu.pc + args[0] + 1
    end

    opcode(:call, [:pc]) do |cpu, memory, offset, args|
      next_pc = cpu.pc + 2
      cpu.sram.memory[cpu.sp.value].value = (next_pc & 0xff00) >> 8
      cpu.sp.decrement
      cpu.sram.memory[cpu.sp.value].value = (next_pc & 0x00ff)
      cpu.sp.decrement
      cpu.pc = args[0]
    end

    opcode(:rcall, [:relative_pc]) do |cpu, memory, offset, args|
      next_pc = cpu.pc + 1
      cpu.sram.memory[cpu.sp.value].value = (next_pc & 0xff00) >> 8
      cpu.sp.decrement
      cpu.sram.memory[cpu.sp.value].value = (next_pc & 0x00ff)
      cpu.sp.decrement
      cpu.pc = cpu.pc + args[0] + 1
    end
  end
end