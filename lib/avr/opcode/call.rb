module AVR
  class Opcode
    opcode(:call, [:pc]) do |cpu, memory, offset, args|
      next_pc = cpu.pc + 2
      cpu.sram.memory[cpu.sp.value].value = (next_pc & 0xff00) >> 8
      cpu.sp.decrement
      cpu.sram.memory[cpu.sp.value].value = (next_pc & 0x00ff)
      cpu.sp.decrement
      cpu.pc = args[0]
    end
  end
end