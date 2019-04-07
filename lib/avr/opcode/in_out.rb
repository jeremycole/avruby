module AVR
  class Opcode
    opcode(:in, [:register, :io_address]) do |cpu, memory, offset, args|
      reg = AVR::CPU::IO_REGISTERS[args[1]]
      args[0].value = cpu.send(reg).value
    end

    opcode(:out, [:io_address, :register]) do |cpu, memory, offset, args|
      reg = AVR::CPU::IO_REGISTERS[args[0]]
      cpu.send(reg).value = args[1].value
    end
  end
end