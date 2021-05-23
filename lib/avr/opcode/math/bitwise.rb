# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    sig { params(cpu: CPU, value: Integer).void }
    def self.set_sreg_for_and_or(cpu, value)
      r7 = (value & (1 << 7)) != 0

      cpu.sreg.from_h({ S: r7 ^ false, V: false, N: r7, Z: value.zero? })
    end

    decode("0010 00rd dddd rrrr", :and) do |cpu, _opcode_definition, operands|
      if operands.fetch(:Rd) == operands.fetch(:Rr)
        cpu.instruction(:tst, operands.fetch(:Rd))
      else
        cpu.instruction(:and, operands.fetch(:Rd), operands.fetch(:Rr))
      end
    end

    opcode(:and, [Arg.register, Arg.register], [:S, :V, :N, :Z]) do |cpu, _memory, args|
      result = (args.fetch(0).value & args.fetch(1).value)
      set_sreg_for_and_or(cpu, result)
      args.fetch(0).value = result
    end

    opcode(:tst, [Arg.register], [:S, :V, :N, :Z]) do |cpu, _memory, args|
      set_sreg_for_and_or(cpu, args.fetch(0).value)
    end

    decode("0111 KKKK dddd KKKK", :andi) do |cpu, _opcode_definition, operands|
      cpu.instruction(:andi, operands.fetch(:Rd), operands.fetch(:K))
    end

    opcode(:andi, [Arg.register, Arg.byte], [:S, :V, :N, :Z]) do |cpu, _memory, args|
      result = (args.fetch(0).value & args.fetch(1).value)
      set_sreg_for_and_or(cpu, result)
      args.fetch(0).value = result
    end

    decode("0010 01rd dddd rrrr", :eor) do |cpu, _opcode_definition, operands|
      cpu.instruction(:eor, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:eor, [Arg.register, Arg.register], [:S, :V, :N, :Z]) do |cpu, _memory, args|
      result = (args.fetch(0).value ^ args.fetch(1).value)
      set_sreg_for_and_or(cpu, result)
      args.fetch(0).value = result
    end

    decode("0010 10rd dddd rrrr", :or) do |cpu, _opcode_definition, operands|
      cpu.instruction(:or, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:or, [Arg.register, Arg.register], [:S, :V, :N, :Z]) do |cpu, _memory, args|
      result = (args.fetch(0).value | args.fetch(1).value)
      set_sreg_for_and_or(cpu, result)
      args.fetch(0).value = result
    end

    decode("0110 KKKK dddd KKKK", :ori) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ori, operands.fetch(:Rd), operands.fetch(:K))
    end

    opcode(:ori, [Arg.register, Arg.byte], [:S, :V, :N, :Z]) do |cpu, _memory, args|
      result = (args.fetch(0).value | args.fetch(1).value)
      set_sreg_for_and_or(cpu, result)
      args.fetch(0).value = result
    end

    decode("1001 010d dddd 0010", :swap) do |cpu, _opcode_definition, operands|
      cpu.instruction(:swap, operands.fetch(:Rd))
    end

    opcode(:swap, [Arg.register]) do |_cpu, _memory, args|
      result = ((args.fetch(0).value & 0xf0) >> 4) | ((args.fetch(0).value & 0x0f) << 4)
      args.fetch(0).value = result
    end

    decode("1001 010d dddd 0000", :com) do |cpu, _opcode_definition, operands|
      cpu.instruction(:com, operands.fetch(:Rd))
    end

    opcode(:com, [Arg.register], [:S, :V, :N, :Z, :C]) do |cpu, _memory, args|
      result = 0xff - args.fetch(0).value

      s = ((result & 0x80) != 0) ^ false
      n = (result & 0x80) != 0

      cpu.sreg.from_h({ S: s, V: false, N: n, Z: result.zero?, C: true })
      args.fetch(0).value = result
    end

    # There is no specific opcode for LSL Rd; it is encoded as ADD Rd, Rd.
    # decode('0000 11dd dddd dddd', :lsl) ...

    opcode(:lsl, [Arg.register], [:H, :S, :V, :N, :Z, :C]) do |cpu, _memory, args|
      result = (args.fetch(0).value << 1) & 0xff

      h = (args.fetch(0).value & (1 << 3)) != 0
      n = (result & (1 << 7)) != 0
      c = (args.fetch(0).value & (1 << 7)) != 0
      v = n ^ c
      s = n ^ v

      cpu.sreg.from_h({ H: h, S: s, V: v, N: n, Z: result.zero?, C: c })
      args.fetch(0).value = result
    end

    decode("1001 010d dddd 0110", :lsr) do |cpu, _opcode_definition, operands|
      cpu.instruction(:lsr, operands.fetch(:Rd))
    end

    opcode(:lsr, [Arg.register], [:S, :V, :N, :Z, :C]) do |cpu, _memory, args|
      result = args.fetch(0).value >> 1

      n = false
      c = (args.fetch(0).value & 1) != 0
      v = n ^ c
      s = n ^ v

      cpu.sreg.from_h({ S: s, V: v, N: n, Z: result.zero?, C: c })
      args.fetch(0).value = result
    end

    # There is no specific opcode for ROL Rd; it is encoded as ADC Rd, Rd.
    # decode('0000 11dd dddd dddd', :rol) ...

    opcode(:rol, [Arg.register], [:S, :V, :N, :Z, :C]) do |cpu, _memory, args|
      result = args.fetch(0).value << 1 | (cpu.sreg.C ? 0x01 : 0)

      h = (result & (1 << 3)) != 0
      n = (result & (1 << 7)) != 0
      c = (args.fetch(0).value & 0xff) != 0
      v = n ^ c
      s = n ^ v

      cpu.sreg.from_h({ H: h, S: s, V: v, N: n, Z: result.zero?, C: c })
      args.fetch(0).value = result
    end

    decode("1001 010d dddd 0111", :ror) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ror, operands.fetch(:Rd))
    end

    opcode(:ror, [Arg.register], [:S, :V, :N, :Z, :C]) do |cpu, _memory, args|
      result = args.fetch(0).value >> 1 | (cpu.sreg.C ? 0x80 : 0)

      n = (result & (1 << 7)) != 0
      c = (args.fetch(0).value & 0x01) != 0
      v = n ^ c
      s = n ^ v

      cpu.sreg.from_h({ S: s, V: v, N: n, Z: result.zero?, C: c })
      args.fetch(0).value = result
    end

    decode("1001 010d dddd 0101", :asr) do |cpu, _opcode_definition, operands|
      cpu.instruction(:asr, operands.fetch(:Rd))
    end

    opcode(:asr, [Arg.register], [:S, :V, :N, :Z, :C]) do |cpu, _memory, args|
      result = (args.fetch(0).value >> 1) | (args.fetch(0).value & 0x80)

      n = (result & (1 << 7)) != 0
      c = (args.fetch(0).value & 1) != 0
      v = n ^ c
      s = n ^ v

      cpu.sreg.from_h({ S: s, V: v, N: n, Z: result.zero?, C: c })
      args.fetch(0).value = result
    end

    decode("1001 010d dddd 0001", :neg) do |cpu, _opcode_definition, operands|
      cpu.instruction(:neg, operands.fetch(:Rd))
    end

    opcode(:neg, [Arg.register], [:H, :S, :V, :N, :Z, :C]) do |cpu, _memory, args|
      result = ((0xff - args.fetch(0).value) + 1) & 0xff

      h = ((args.fetch(0).value & (1 << 3)) & (result & (1 << 3))) != 0 # ???
      n = (result & (1 << 7)) != 0
      c = result != 0x00
      v = result & 0x80
      s = n ^ v

      cpu.sreg.from_h({ H: h, S: s, V: v, N: n, Z: result.zero?, C: c })
      args.fetch(0).value = result
    end
  end
end
