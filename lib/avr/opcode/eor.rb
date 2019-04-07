module AVR
  class Opcode
    opcode(:eor, [:register, :register]) do |cpu, memory, offset, args|
      result = (args[0].value ^ args[1].value)
      cpu.sreg.S = false # TODO
      cpu.sreg.V = false
      cpu.sreg.N = ((result & 0x80) == 0x80)
      cpu.sreg.Z = (result == 0)
      args[0].value = result
    end
  end
end
