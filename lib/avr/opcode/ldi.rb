module AVR
  class Opcode
    opcode(:ldi, [:register, :constant]) do |cpu, memory, offset, args|
      args[0].value = args[1]
    end
  end
end