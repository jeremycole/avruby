module AVR
  class Opcode
    opcode(:subi, [:register, :byte]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1]) % 0xff
      cpu.sreg.set_by_hash({
        H: false, # TODO
        S: false, # TODO
        V: result > args[0].value,
        N: (result & 0x80) == 0x80,
        Z: result == 0,
        C: args[1] > args[0].value,
      })
      args[0].value = result
    end

    opcode(:sbci, [:register, :byte]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1] - (cpu.sreg.C ? 1 : 0)) % 0xff
      cpu.sreg.set_by_hash({
        H: false, # TODO
        S: false, # TODO
        V: result > args[0].value,
        N: (result & 0x80) == 0x80,
        Z: result == 0,
        C: args[1] > args[0].value,
      })
      args[0].value = result
    end
  end
end