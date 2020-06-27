# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    sig { params(cpu: CPU, value: Integer).void }
    def self.set_sreg_for_and_or(cpu, value)
      r7 = (value & (1 << 7)) != 0

      cpu.sreg.from_h(
        {
          S: r7 ^ false,
          V: false,
          N: r7,
          Z: value.zero?,
        }
      )
    end

    decode('0010 00rd dddd rrrr', :and) do |cpu, _opcode_definition, operands|
      cpu.instruction(:and, operands[:Rd], operands[:Rr])
    end

    opcode(:and, %i[register register], %i[S V N Z]) do |cpu, _memory, args|
      result = (args[0].value & args[1].value)
      set_sreg_for_and_or(cpu, result)
      args[0].value = result
    end

    decode('0111 KKKK dddd KKKK', :andi) do |cpu, _opcode_definition, operands|
      cpu.instruction(:andi, operands[:Rd], operands[:K])
    end

    opcode(:andi, %i[register byte], %i[S V N Z]) do |cpu, _memory, args|
      result = (args[0].value & args[1])
      set_sreg_for_and_or(cpu, result)
      args[0].value = result
    end

    decode('0010 01rd dddd rrrr', :eor) do |cpu, _opcode_definition, operands|
      cpu.instruction(:eor, operands[:Rd], operands[:Rr])
    end

    opcode(:eor, %i[register register], %i[S V N Z]) do |cpu, _memory, args|
      result = (args[0].value ^ args[1].value)
      set_sreg_for_and_or(cpu, result)
      args[0].value = result
    end

    decode('0010 10rd dddd rrrr', :or) do |cpu, _opcode_definition, operands|
      cpu.instruction(:or, operands[:Rd], operands[:Rr])
    end

    opcode(:or, %i[register register], %i[S V N Z]) do |cpu, _memory, args|
      result = (args[0].value | args[1].value)
      set_sreg_for_and_or(cpu, result)
      args[0].value = result
    end

    decode('0110 KKKK dddd KKKK', :ori) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ori, operands[:Rd], operands[:K])
    end

    opcode(:ori, %i[register byte], %i[S V N Z]) do |cpu, _memory, args|
      result = (args[0].value | args[1])
      set_sreg_for_and_or(cpu, result)
      args[0].value = result
    end

    decode('1001 010d dddd 0010', :swap) do |cpu, _opcode_definition, operands|
      cpu.instruction(:swap, operands[:Rd])
    end

    opcode(:swap, %i[register]) do |_cpu, _memory, args|
      result = ((args[0].value & 0xf0) >> 4) | ((args[0].value & 0x0f) << 4)
      args[0].value = result
    end

    decode('1001 010d dddd 0000', :com) do |cpu, _opcode_definition, operands|
      cpu.instruction(:com, operands[:Rd])
    end

    opcode(:com, %i[register], %i[S V N Z C]) do |cpu, _memory, args|
      result = 0xff - args[0].value
      cpu.sreg.from_h(
        {
          S: ((result & 0x80) != 0) ^ false,
          V: false,
          N: (result & 0x80) != 0,
          Z: result.zero?,
          C: true,
        }
      )
      args[0].value = result
    end

    # There is no specific opcode for LSL Rd; it is encoded as ADD Rd, Rd.
    # decode('0000 11dd dddd dddd', :lsl) ...

    opcode(:lsl, %i[register], %i[H S V N Z C]) do |cpu, _memory, args|
      result = (args[0].value << 1) & 0xff

      h = (args[0].value & (1 << 3)) != 0
      n = (result & (1 << 7)) != 0
      c = (args[0].value & (1 << 7)) != 0
      v = n ^ c
      s = n ^ v
      cpu.sreg.from_h(
        {
          H: h,
          S: s,
          V: v,
          N: n,
          Z: result.zero?,
          C: c,
        }
      )

      args[0].value = result
    end

    decode('1001 010d dddd 0110', :lsr) do |cpu, _opcode_definition, operands|
      cpu.instruction(:lsr, operands[:Rd])
    end

    opcode(:lsr, %i[register], %i[S V N Z C]) do |cpu, _memory, args|
      result = args[0].value >> 1

      n = false
      c = (args[0].value & 1) != 0
      v = n ^ c
      s = n ^ v
      cpu.sreg.from_h(
        {
          S: s,
          V: v,
          N: n,
          Z: result.zero?,
          C: c,
        }
      )

      args[0].value = result
    end

    decode('1001 010d dddd 0101', :asr) do |cpu, _opcode_definition, operands|
      cpu.instruction(:asr, operands[:Rd])
    end

    opcode(:asr, %i[register], %i[S V N Z C]) do |cpu, _memory, args|
      result = (args[0].value >> 1) | (args[0].value & 0x80)

      n = (result & (1 << 7)) != 0
      c = (args[0].value & 1) != 0
      v = n ^ c
      s = n ^ v
      cpu.sreg.from_h(
        {
          S: s,
          V: v,
          N: n,
          Z: result.zero?,
          C: c,
        }
      )

      args[0].value = result
    end
  end
end
