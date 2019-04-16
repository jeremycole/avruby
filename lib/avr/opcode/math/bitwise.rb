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

    decode("0010 00rd dddd rrrr", :and) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :and, operands[:Rd], operands[:Rr])
    end

    opcode(:and, [:register, :register], %i[S V N Z]) do |cpu, memory, offset, args|
      result = (args[0].value & args[1].value)
      set_sreg_for_and_or(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    decode("0111 KKKK dddd KKKK", :andi) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :andi, operands[:Rd], operands[:K])
    end

    opcode(:andi, [:register, :byte], %i[S V N Z]) do |cpu, memory, offset, args|
      result = (args[0].value & args[1])
      set_sreg_for_and_or(cpu, result, args[0].value, args[1])
      args[0].value = result
    end

    decode("0010 01rd dddd rrrr", :eor) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :eor, operands[:Rd], operands[:Rr])
    end

    opcode(:eor, [:register, :register], %i[S V N Z]) do |cpu, memory, offset, args|
      result = (args[0].value ^ args[1].value)
      set_sreg_for_and_or(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    decode("0010 10rd dddd rrrr", :or) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :or, operands[:Rd], operands[:Rr])
    end

    opcode(:or, [:register, :register], %i[S V N Z]) do |cpu, memory, offset, args|
      result = (args[0].value | args[1].value)
      set_sreg_for_and_or(cpu, result, args[0].value, args[1].value)
      args[0].value = result
    end

    decode("0110 KKKK dddd KKKK", :ori) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :ori, operands[:Rd], operands[:K])
    end

    opcode(:ori, [:register, :byte], %i[S V N Z]) do |cpu, memory, offset, args|
      result = (args[0].value | args[1])
      set_sreg_for_and_or(cpu, result, args[0].value, args[1])
      args[0].value = result
    end

    decode("1001 0100 0sss 1000", :bset) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :bset, operands[:s])
    end

    opcode(:bset, [:sreg_flag], %i[I T H S V N Z C]) do |cpu, memory, offset, args|
      cpu.sreg.set_by_hash({args[0] => true});
    end

    decode("1001 0100 1sss 1000", :bclr) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :bclr, operands[:s])
    end

    opcode(:bclr, [:sreg_flag], %i[I T H S V N Z C]) do |cpu, memory, offset, args|
      cpu.sreg.set_by_hash({args[0] => false});
    end

    decode("1001 010d dddd 0010", :swap) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :swap, operands[:Rd])
    end

    opcode(:swap, [:register]) do |cpu, memory, offset, args|
      result = ((args[0].value & 0xf0) >> 4) | ((args[0].value & 0x0f) << 4)
      args[0].value = result
    end
  end
end
