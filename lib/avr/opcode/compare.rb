module AVR
  class Opcode
    def self.set_sreg_for_cp_cpi_cpc(cpu, r, rd, rr_k, opcode)
      b7  = (1<<7)
      b3  = (1<<3)
      r7  = (r  & b7) != 0
      rd7 = (rd & b7) != 0
      rr_k7 = (rr_k & b7) != 0
      r3  = (r  & b7) != 0
      rd3 = (rd & b7) != 0
      rr_k3 = (rr_k & b7) != 0
      n   = r7
      v   = rd7 & rr_k7 & r7 | !rd7 & rr_k7 & r7
      c   = !rd7 & rr_k7 | rr_k7 & r7 | r7 & !rd7
      h   = !rd3 & rr_k3 | rr_k3 & r3 | r3 & !rd3

      z = if opcode == :cpc
        (r == 0) ? cpu.sreg.Z : false
      else
        (r == 0)
      end

      cpu.sreg.set_by_hash({
        H: h,
        S: n ^ v,
        V: v,
        N: n,
        Z: z,
        C: c,
      })
    end

    opcode(:cp, [:register, :register], %i[H S V N Z C]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1].value) & 0xff
      set_sreg_for_cp_cpi_cpc(cpu, result, args[0].value, args[1].value, :cp)
    end

    opcode(:cpc, [:register, :register], %i[H S V N Z C]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1].value - (cpu.sreg.C ? 1 : 0)) & 0xff
      set_sreg_for_cp_cpi_cpc(cpu, result, args[0].value, args[1].value, :cpc)
    end

    opcode(:cpi, [:register, :byte], %i[H S V N Z C]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1]) & 0xff
      set_sreg_for_cp_cpi_cpc(cpu, result, args[0].value, args[1], :cpi)
    end
  end
end