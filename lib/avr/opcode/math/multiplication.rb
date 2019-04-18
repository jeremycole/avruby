module AVR
  class Opcode
    decode("1001 11rd dddd rrrr", :mul) do |cpu, opcode_definition, operands|
      cpu.instruction(:mul, operands[:Rd], operands[:Rr])
    end

    opcode(:mul, [:register, :register], %i[Z C]) do |cpu, memory, args|
      result = (args[0].value * args[1].value)
      set_sreg_for_inc(cpu, result, args[0].value)
      cpu.sreg.set_by_hash({
        Z: result == 0,
        C: (result & 0x8000) != 0,
      })
      cpu.r0 = result & 0x00ff
      cpu.r1 = (result & 0xff00) >> 8
    end
  end
end