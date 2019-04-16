module AVR
  class Opcode
    decode("0010 11rd dddd rrrr", :mov) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :mov, operands[:Rd], operands[:Rr])
    end

    opcode(:mov, [:register, :register]) do |cpu, memory, offset, args|
      args[0].value = args[1].value
    end

    decode("0000 0001 dddd rrrr", :movw) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :movw, operands[:Rd], operands[:Rr])
    end

    opcode(:movw, [:word_register, :word_register]) do |cpu, memory, offset, args|
      args[0].value = args[1].value
    end
  end
end