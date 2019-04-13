module AVR
  class Opcode
    opcode(:mov, [:register, :register]) do |cpu, memory, offset, args|
      args[0].value = args[1].value
    end
  end
end