module AVR
  class Opcode
    opcode(:push, [:register]) do |cpu, memory, offset, args|
      cpu.sram.memory[cpu.sp.value].value = args[0].value
      cpu.sp.decrement
    end

    opcode(:pop, [:register]) do |cpu, memory, offset, args|
      cpu.sp.increment
      args[0].value = cpu.sram.memory[cpu.sp.value].value
    end
  end
end