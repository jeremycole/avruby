module AVR
  class Opcode
    opcode(:add, [:register, :register]) do |cpu, memory, offset, args|
      result = (args[0].value + args[1].value)
      cpu.sreg.set_by_hash({
        S: false, # TODO
        V: false, # TODO
        N: ((result & 0x80) == 0x80),
        Z: (result == 0),
        C: (result > 0xff),
      })
      args[0].value = result & 0xff
    end
  end
end
