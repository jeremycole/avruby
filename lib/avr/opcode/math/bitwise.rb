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

    decode("0010 00rd dddd rrrr", :and) do |cpu, opcode_definition, operands|
      cpu.instruction(:and, operands[:Rd], operands[:Rr])
    end

    opcode(:and, [:register, :register], %i[S V N Z]) do |cpu, memory, args|
      result = (args[0].value & args[1].value)
      set_sreg_for_and_or(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    decode("0111 KKKK dddd KKKK", :andi) do |cpu, opcode_definition, operands|
      cpu.instruction(:andi, operands[:Rd], operands[:K])
    end

    opcode(:andi, [:register, :byte], %i[S V N Z]) do |cpu, memory, args|
      result = (args[0].value & args[1])
      set_sreg_for_and_or(cpu, result, args[0].value, args[1])
      args[0].value = result
    end

    decode("0010 01rd dddd rrrr", :eor) do |cpu, opcode_definition, operands|
      cpu.instruction(:eor, operands[:Rd], operands[:Rr])
    end

    opcode(:eor, [:register, :register], %i[S V N Z]) do |cpu, memory, args|
      result = (args[0].value ^ args[1].value)
      set_sreg_for_and_or(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    decode("0010 10rd dddd rrrr", :or) do |cpu, opcode_definition, operands|
      cpu.instruction(:or, operands[:Rd], operands[:Rr])
    end

    opcode(:or, [:register, :register], %i[S V N Z]) do |cpu, memory, args|
      result = (args[0].value | args[1].value)
      set_sreg_for_and_or(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    decode("0110 KKKK dddd KKKK", :ori) do |cpu, opcode_definition, operands|
      cpu.instruction(:ori, operands[:Rd], operands[:K])
    end

    opcode(:ori, [:register, :byte], %i[S V N Z]) do |cpu, memory, args|
      result = (args[0].value | args[1])
      set_sreg_for_and_or(cpu, result, args[0].value, args[1])
      args[0].value = result
    end

    decode("1001 010d dddd 0010", :swap) do |cpu, opcode_definition, operands|
      cpu.instruction(:swap, operands[:Rd])
    end

    opcode(:swap, [:register]) do |cpu, memory, args|
      result = ((args[0].value & 0xf0) >> 4) | ((args[0].value & 0x0f) << 4)
      args[0].value = result
    end

    decode("1001 010d dddd 0000", :com) do |cpu, opcode_definition, operands|
      cpu.instruction(:com, operands[:Rd])
    end

    opcode(:com, [:register], %i[S V N Z C]) do |cpu, memory, args|
      result = 0xff - args[0].value
      cpu.sreg.set_by_hash({
        S: ((result & 0x80) != 0) ^ false,
        V: false,
        N: (result & 0x80) != 0,
        Z: result == 0,
        C: true,
      })
      args[0].value = result
    end

    # There is no specific opcode for LSL Rd; it is encoded as ADD Rd, Rd.
    # decode("0000 11dd dddd dddd", :lsl) ...

    opcode(:lsl, [:register], %i[H S V N Z C]) do |cpu, memory, args|
      result = (args[0].value << 1) & 0xff

      h = (args[0].value & (1<<3)) != 0
      n = (result & (1<<7)) != 0
      c = (args[0].value & (1<<7)) != 0
      v = n ^ c
      s = n ^ v
      cpu.sreg.set_by_hash({
        H: h,
        S: s,
        V: v,
        N: n,
        Z: (result == 0),
        C: c,
      })

      args[0].value = result
    end

    decode("1001 010d dddd 0110", :lsr) do |cpu, opcode_definition, operands|
      cpu.instruction(:lsr, operands[:Rd])
    end

    opcode(:lsr, [:register], %i[S V N Z C]) do |cpu, memory, args|
      result = args[0].value >> 1

      n = false
      c = (args[0].value & 1) != 0
      v = n ^ c
      s = n ^ v
      cpu.sreg.set_by_hash({
        S: s,
        V: v,
        N: n,
        Z: (result == 0),
        C: c,
      })

      args[0].value = result
    end

    decode("1001 010d dddd 0101", :asr) do |cpu, opcode_definition, operands|
      cpu.instruction(:asr, opcode[:Rd])
    end

    opcode(:asr, [:register], %i[S V N Z C]) do |cpu, memory, args|
      result = ((args[0].value) >> 1) | (args[0].value & 0x80)

      n = (result & (1<<7)) != 0
      c = (args[0].value & 1) != 0
      v = n ^ c
      s = n ^ v
      cpu.sreg.set_by_hash({
        S: s,
        V: v,
        N: n,
        Z: (result == 0),
        C: c,
      })

      args[0].value = result
    end
  end
end
