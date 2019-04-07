module AVR
  class Opcode
    opcode(:jmp, [:pc]) do |cpu, memory, offset, args|
      cpu.pc = args[0]
    end
  end
end