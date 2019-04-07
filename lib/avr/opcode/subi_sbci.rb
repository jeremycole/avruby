module AVR
  class Opcode
    opcode(:subi, [:register, :constant]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1]) % 256
      cpu.sreg.H = false # TODO
      cpu.sreg.S = false # TODO
      cpu.sreg.V = result > args[0].value
      cpu.sreg.N = (result & 0x80) == 0x80
      cpu.sreg.Z = result == 0
      cpu.sreg.C = args[1] > args[0].value
      args[0].value = result
    end

    opcode(:sbci, [:register, :constant]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1] - (cpu.sreg.C ? 1 : 0)) % 256
      cpu.sreg.H = false # TODO
      cpu.sreg.S = false # TODO
      cpu.sreg.V = result > args[0].value
      cpu.sreg.N = (result & 0x80) == 0x80
      cpu.sreg.Z = result == 0
      cpu.sreg.C = args[1] > args[0].value
      args[0].value = result
    end
  end
end