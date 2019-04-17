module AVR
  class Opcode
    decode("1011 0AAd dddd AAAA", :in) do |cpu, opcode_definition, operands|
      cpu.instruction(:in, operands[:Rd], operands[:A])
    end

    opcode(:in, [:register, :io_address]) do |cpu, memory, args|
      reg = cpu.device.io_registers[args[1]]
      args[0].value = cpu.send(reg).value
    end

    decode("1011 1AAr rrrr AAAA", :out) do |cpu, opcode_definition, operands|
      cpu.instruction(:out, operands[:A], operands[:Rr])
    end

    opcode(:out, [:io_address, :register]) do |cpu, memory, args|
      reg = cpu.device.io_registers[args[0]]
      cpu.send(reg).value = args[1].value
    end
  end
end