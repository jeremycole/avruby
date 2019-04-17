module AVR
  class Opcode
    decode("0010 11rd dddd rrrr", :mov) do |cpu, opcode_definition, operands|
      cpu.instruction(:mov, operands[:Rd], operands[:Rr])
    end

    opcode(:mov, [:register, :register]) do |cpu, memory, args|
      args[0].value = args[1].value
    end

    parse_operands("____ ____ dddd rrrr") do |cpu, operands|
      {
        Rd: cpu.registers.associated_word_register(cpu.registers[operands[:d] << 1]),
        Rr: cpu.registers.associated_word_register(cpu.registers[operands[:r] << 1]),
      }
    end

    decode("0000 0001 dddd rrrr", :movw) do |cpu, opcode_definition, operands|
      cpu.instruction(:movw, operands[:Rd], operands[:Rr])
    end

    opcode(:movw, [:word_register, :word_register]) do |cpu, memory, args|
      args[0].value = args[1].value
    end
  end
end