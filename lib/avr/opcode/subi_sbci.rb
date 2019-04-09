module AVR
  class Opcode
    opcode(:subi, [:register, :constant]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1]) % 256
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

    opcode(:sbci, [:register, :constant]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1] - (cpu.sreg.C ? 1 : 0)) % 256
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