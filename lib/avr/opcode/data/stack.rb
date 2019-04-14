module AVR
  class Opcode
    opcode(:push, [:register]) do |cpu, memory, offset, args|
      stack_push(cpu, args[0].value)
    end

    opcode(:pop, [:register]) do |cpu, memory, offset, args|
      args[0].value = stack_pop(cpu)
    end
  end
end