# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode('1001 11rd dddd rrrr', :mul) do |cpu, _opcode_definition, operands|
      cpu.instruction(:mul, operands[:Rd], operands[:Rr])
    end

    opcode(:mul, %i[register register], %i[Z C]) do |cpu, _memory, args|
      result = (args[0].value * args[1].value)
      set_sreg_for_inc(cpu, result, args[0].value)
      cpu.sreg.from_h(
        {
          Z: result.zero?,
          C: (result & 0x8000) != 0,
        }
      )
      cpu.r0 = result & 0x00ff
      cpu.r1 = (result & 0xff00) >> 8
    end
  end
end
