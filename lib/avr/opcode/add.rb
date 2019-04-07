module AVR
  class Opcode
    opcode(:add, [:register, :register]) do |cpu, memory, offset, args|
      result = (args[0].value + args[1].value)
      cpu.sreg.N = false # TODO
      cpu.sreg.S = false # TODO
      cpu.sreg.V = false # TODO
      cpu.sreg.N = ((result & 0x80) == 0x80)
      cpu.sreg.Z = (result == 0)
      cpu.sreg.C = (result > 0xff)
      args[0].value = result & 0xff
    end
  end
end
