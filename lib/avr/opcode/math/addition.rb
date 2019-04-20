module AVR
  class Opcode
    def self.set_sreg_for_inc(cpu, r, rd)
      n = (r & (1<<7)) != 0
      v = (rd == 0x7f)

      cpu.sreg.set_by_hash({
        S: n ^ v,
        V: v,
        N: n,
        Z: (r == 0),
      })
    end

    decode("1001 101d dddd 0011", :inc) do |cpu, opcode_definition, operands|
      cpu.instruction(:inc, operands[:Rd])
    end

    opcode(:inc, [:register], %i[S V N Z]) do |cpu, memory, args|
      result = (args[0].value + 1) & 0xff
      set_sreg_for_inc(cpu, result, args[0].value)
      args[0].value = result
    end

    def self.set_sreg_for_add_adc(cpu, r, rd, rr)
      b7  = (1<<7)
      b3  = (1<<3)
      r7  = (r  & b7) != 0
      rd7 = (rd & b7) != 0
      rr7 = (rr & b7) != 0
      r3  = (r  & b7) != 0
      rd3 = (rd & b7) != 0
      rr3 = (rr & b7) != 0
      n   = r7
      v   = rd7 & rr7 & !r7 | !rd7 & !rr7 & r7
      c   = rd7 & rr7 | rr7 & !r7 | !r7 & rd7
      h   = rd3 & rr3 | rr3 & !r3 | !r3 & rd3

      cpu.sreg.set_by_hash({
        H: h,
        S: n ^ v,
        V: v,
        N: n,
        Z: (r == 0),
        C: c,
      })
    end

    decode("0000 11rd dddd rrrr", :add) do |cpu, opcode_definition, operands|
      if operands[:Rd] == operands[:Rr]
        cpu.instruction(:lsl, operands[:Rd])
      else
        cpu.instruction(:add, operands[:Rd], operands[:Rr])
      end
    end

    opcode(:add, [:register, :register], %i[H S V N Z C]) do |cpu, memory, args|
      result = (args[0].value + args[1].value) & 0xff
      set_sreg_for_add_adc(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    decode("0001 11rd dddd rrrr", :adc) do |cpu, opcode_definition, operands|
      cpu.instruction(:adc, operands[:Rd], operands[:Rr])
    end

    opcode(:adc, [:register, :register], %i[H S V N Z C]) do |cpu, memory, args|
      result = (args[0].value + args[1].value + (cpu.sreg.C ? 1 : 0)) & 0xff
      set_sreg_for_add_adc(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    def self.set_sreg_for_adiw(cpu, r, rd, k)
      b15  = (1<<15)
      b7   = (1<<7)
      rdh7 = (rd & b7) != 0
      r15  = (r & b15) != 0
      v   = !rdh7 & r15
      n   = r15
      c   = !r15 & rdh7

      cpu.sreg.set_by_hash({
        S: n ^ v,
        V: v,
        N: n,
        Z: (r == 0),
        C: c,
      })
    end

    decode("1001 0110 KKdd KKKK", :adiw) do |cpu, opcode_definition, operands|
      cpu.instruction(:adiw, operands[:Rd], operands[:K])
    end

    opcode(:adiw, [:word_register, :byte], %i[S V N Z C]) do |cpu, memory, args|
      result = (args[0].value + args[1]) & 0xffff
      set_sreg_for_adiw(cpu, result, args[0].value, args[1])
      args[0].value = result
    end
  end
end
