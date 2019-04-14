module AVR
  class Opcode
    opcode(:ldi, [:register, :byte]) do |cpu, memory, offset, args|
      args[0].value = args[1]
    end
  end
end