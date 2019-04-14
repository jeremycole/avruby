module AVR
  class Opcode
    def self.set_sreg_for_sub_sbc(cpu, r, rd, rr)
      b7  = (1<<7)
      b3  = (1<<3)
      r7  = (r  & b7) != 0
      rd7 = (rd & b7) != 0
      rr7 = (rr & b7) != 0
      r3  = (r  & b7) != 0
      rd3 = (rd & b7) != 0
      rr3 = (rr & b7) != 0

      n   = r7
      v   = rd7 & rr7 & !r7 | !rd7 & rr7 & r7
      c   = !rd7 & rr7 | rr7 & r7 | r7 & !rd7
      h   = !rd3 & rr3 | rr3 & r3 | r3 & !rd3

      cpu.sreg.set_by_hash({
        H: h,
        S: n ^ v,
        V: v,
        N: n,
        Z: (r == 0),
        C: c,
      })
    end

    opcode(:sub, [:register, :register], %i[H S V N Z C]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1].value) & 0xff
      set_sreg_for_sub_sbc(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    opcode(:subi, [:register, :byte], %i[H S V N Z C]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1]) & 0xff
      set_sreg_for_sub_sbc(cpu, result, args[0].value, args[1])
      args[0].value = result
    end

    opcode(:sbc, [:register, :register], %i[H S V N Z C]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1].value - (cpu.sreg.C ? 1 : 0)) & 0xff
      set_sreg_for_sub_sbc(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    opcode(:sbci, [:register, :byte], %i[H S V N Z C]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1] - (cpu.sreg.C ? 1 : 0)) & 0xff
      set_sreg_for_sub_sbc(cpu, result, args[0].value, args[1])
      args[0].value = result
    end
  end
end