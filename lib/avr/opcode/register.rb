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
        Rd: [
          cpu.registers[(operands[:d] << 1) + 1],
          cpu.registers[operands[:d] << 1],
        ],
        Rr: [
          cpu.registers[(operands[:r] << 1) + 1],
          cpu.registers[operands[:r] << 1],
        ],
      }
    end

    decode("0000 0001 dddd rrrr", :movw) do |cpu, opcode_definition, operands|
      cpu.instruction(:movw, operands[:Rd], operands[:Rr])
    end

    opcode(:movw, [:register_pair, :register_pair]) do |cpu, memory, args|
      args[0][0].value = args[1][0].value
      args[0][1].value = args[1][1].value
    end
  end
end