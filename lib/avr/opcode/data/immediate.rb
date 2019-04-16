module AVR
  class Opcode
    decode("1110 KKKK dddd KKKK", :ldi) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :ldi, operands[:Rd], operands[:K])
    end

    opcode(:ldi, [:register, :byte]) do |cpu, memory, offset, args|
      args[0].value = args[1]
    end
  end
end