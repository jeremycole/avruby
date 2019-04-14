module AVR
  class Opcode
    def self.set_sreg_for_and_or(cpu, r, rd, rr)
      r7  = (r & (1<<7)) != 0

      cpu.sreg.set_by_hash({
        S: r7 ^ false,
        V: false,
        N: r7,
        Z: (r == 0),
      })
    end

    opcode(:and, [:register, :register], %i[S V N Z]) do |cpu, memory, offset, args|
      result = (args[0].value & args[1].value)
      set_sreg_for_and_or(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    opcode(:andi, [:register, :byte], %i[S V N Z]) do |cpu, memory, offset, args|
      result = (args[0].value & args[1])
      set_sreg_for_and_or(cpu, result, args[0].value, args[1])
      args[0].value = result
    end

    opcode(:eor, [:register, :register], %i[S V N Z]) do |cpu, memory, offset, args|
      result = (args[0].value ^ args[1].value)
      set_sreg_for_and_or(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    opcode(:or, [:register, :register], %i[S V N Z]) do |cpu, memory, offset, args|
      result = (args[0].value | args[1].value)
      set_sreg_for_and_or(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    opcode(:ori, [:register, :byte], %i[S V N Z]) do |cpu, memory, offset, args|
      result = (args[0].value | args[1])
      set_sreg_for_and_or(cpu, result, args[0].value, args[1])
      args[0].value = result
    end

    opcode(:swap, [:register]) do |cpu, memory, offset, args|
      result = ((args[0].value & 0xf0) >> 4) | ((args[0].value & 0x0f) << 4)
      args[0].value = result
    end
  end
end
