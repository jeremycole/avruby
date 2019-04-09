module AVR
  class Opcode
    opcode(:eor, [:register, :register]) do |cpu, memory, offset, args|
      result = (args[0].value ^ args[1].value)
      cpu.sreg.set_by_hash({
        S: false, # TODO
        V: false,
        N: ((result & 0x80) == 0x80),
        Z: (result == 0),
      })
      args[0].value = result
    end
  end
end
