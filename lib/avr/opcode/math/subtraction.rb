module AVR
  class Opcode
    def self.set_sreg_for_dec(cpu, r, rd)
      n = (r & (1<<7)) != 0
      v = (rd == 0x80)

      cpu.sreg.set_by_hash({
        S: n ^ v,
        V: v,
        N: n,
        Z: (r == 0),
      })
    end

    decode("1001 010d dddd 1010", :dec) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :dec, operands[:Rd])
    end

    opcode(:dec, [:register], %i[S V N Z]) do |cpu, memory, offset, args|
      result = (args[0].value - 1) & 0xff
      set_sreg_for_dec(cpu, result, args[0].value)
      args[0].value = result
    end

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

    decode("0001 10rd dddd rrrr", :sub) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :sub, operands[:Rd], operands[:Rr])
    end

    opcode(:sub, [:register, :register], %i[H S V N Z C]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1].value) & 0xff
      set_sreg_for_sub_sbc(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    decode("0101 KKKK dddd KKKK", :subi) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :subi, operands[:Rd], operands[:K])
    end

    opcode(:subi, [:register, :byte], %i[H S V N Z C]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1]) & 0xff
      set_sreg_for_sub_sbc(cpu, result, args[0].value, args[1])
      args[0].value = result
    end

    decode("0000 10rd dddd rrrr", :sbc) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :sbc, operands[:Rd], operands[:Rr])
    end

    opcode(:sbc, [:register, :register], %i[H S V N Z C]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1].value - (cpu.sreg.C ? 1 : 0)) & 0xff
      set_sreg_for_sub_sbc(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    decode("0100 KKKK dddd KKKK", :sbci) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :sbci, operands[:Rd], operands[:K])
    end

    opcode(:sbci, [:register, :byte], %i[H S V N Z C]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1] - (cpu.sreg.C ? 1 : 0)) & 0xff
      set_sreg_for_sub_sbc(cpu, result, args[0].value, args[1])
      args[0].value = result
    end

    def self.set_sreg_for_sbiw(cpu, r, rd, k)
      b15  = (1<<15)
      b7   = (1<<7)
      rdh7 = (rd & b7) != 0
      r15  = (r & b15) != 0
      v   = r15 & !rdh7
      n   = r15
      c   = r15 & !rdh7

      cpu.sreg.set_by_hash({
        S: n ^ v,
        V: v,
        N: n,
        Z: (r == 0),
        C: c,
      })
    end

    decode("1001 0111 KKdd KKKK", :sbiw) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :sbiw, operands[:Rd], operands[:K])
    end

    opcode(:sbiw, [:word_register, :byte], %i[S V N Z C]) do |cpu, memory, offset, args|
      result = (args[0].value - args[1]) & 0xffff
      set_sreg_for_sbiw(cpu, result, args[0].value, args[1])
      args[0].value = result
    end
  end
end