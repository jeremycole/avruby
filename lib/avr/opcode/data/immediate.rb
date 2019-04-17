module AVR
  class Opcode
    decode("1110 KKKK dddd KKKK", :ldi) do |cpu, opcode_definition, operands|
      cpu.instruction(:ldi, operands[:Rd], operands[:K])
    end

    opcode(:ldi, [:register, :byte]) do |cpu, memory, args|
      args[0].value = args[1]
    end
  end
end