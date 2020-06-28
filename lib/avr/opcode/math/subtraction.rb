# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    # rubocop:disable Naming/MethodParameterName
    sig { params(cpu: CPU, r: Integer, rd: Integer).void }
    def self.set_sreg_for_dec(cpu, r, rd)
      n = (r & (1 << 7)) != 0
      v = (rd == 0x80)

      cpu.sreg.from_h(
        {
          S: n ^ v,
          V: v,
          N: n,
          Z: r.zero?,
        }
      )
    end
    # rubocop:enable Naming/MethodParameterName

    decode('1001 010d dddd 1010', :dec) do |cpu, _opcode_definition, operands|
      cpu.instruction(:dec, operands.fetch(:Rd))
    end

    opcode(:dec, %i[register], %i[S V N Z]) do |cpu, _memory, args|
      result = (args.fetch(0).value - 1) & 0xff
      set_sreg_for_dec(cpu, result, args.fetch(0).value)
      args.fetch(0).value = result
    end

    # rubocop:disable Naming/MethodParameterName
    sig { params(cpu: CPU, r: Integer, rd: Integer, rr: Integer).void }
    def self.set_sreg_for_sub_sbc(cpu, r, rd, rr)
      b7  = (1 << 7)
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

      cpu.sreg.from_h(
        {
          H: h,
          S: n ^ v,
          V: v,
          N: n,
          Z: r.zero?,
          C: c,
        }
      )
    end
    # rubocop:enable Naming/MethodParameterName

    decode('0001 10rd dddd rrrr', :sub) do |cpu, _opcode_definition, operands|
      cpu.instruction(:sub, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:sub, %i[register register], %i[H S V N Z C]) do |cpu, _memory, args|
      result = (args.fetch(0).value - args.fetch(1).value) & 0xff
      set_sreg_for_sub_sbc(cpu, result, args.fetch(0).value, args.fetch(1).value)
      args.fetch(0).value = result
    end

    decode('0101 KKKK dddd KKKK', :subi) do |cpu, _opcode_definition, operands|
      cpu.instruction(:subi, operands.fetch(:Rd), operands.fetch(:K))
    end

    opcode(:subi, %i[register byte], %i[H S V N Z C]) do |cpu, _memory, args|
      result = (args.fetch(0).value - args.fetch(1).value) & 0xff
      set_sreg_for_sub_sbc(cpu, result, args.fetch(0).value, args.fetch(1).value)
      args.fetch(0).value = result
    end

    decode('0000 10rd dddd rrrr', :sbc) do |cpu, _opcode_definition, operands|
      cpu.instruction(:sbc, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:sbc, %i[register register], %i[H S V N Z C]) do |cpu, _memory, args|
      result = (args.fetch(0).value - args.fetch(1).value - (cpu.sreg.C ? 1 : 0)) & 0xff
      set_sreg_for_sub_sbc(cpu, result, args.fetch(0).value, args.fetch(1).value)
      args.fetch(0).value = result
    end

    decode('0100 KKKK dddd KKKK', :sbci) do |cpu, _opcode_definition, operands|
      cpu.instruction(:sbci, operands.fetch(:Rd), operands.fetch(:K))
    end

    opcode(:sbci, %i[register byte], %i[H S V N Z C]) do |cpu, _memory, args|
      result = (args.fetch(0).value - args.fetch(1).value - (cpu.sreg.C ? 1 : 0)) & 0xff
      set_sreg_for_sub_sbc(cpu, result, args.fetch(0).value, args.fetch(1).value)
      args.fetch(0).value = result
    end

    # rubocop:disable Naming/MethodParameterName
    # rubocop:disable Layout/SpaceAroundOperators
    sig { params(cpu: CPU, r: Integer, rd: Integer).void }
    def self.set_sreg_for_sbiw(cpu, r, rd)
      b15  = (1 << 15)
      b7   = (1 << 7)
      rdh7 = (rd & b7) != 0
      r15  = (r & b15) != 0
      v   = r15 & !rdh7
      n   = r15
      c   = r15 & !rdh7

      cpu.sreg.from_h(
        {
          S: n ^ v,
          V: v,
          N: n,
          Z: r.zero?,
          C: c,
        }
      )
    end
    # rubocop:enable Layout/SpaceAroundOperators
    # rubocop:enable Naming/MethodParameterName

    decode('1001 0111 KKdd KKKK', :sbiw) do |cpu, _opcode_definition, operands|
      cpu.instruction(:sbiw, operands.fetch(:Rd), operands.fetch(:K))
    end

    opcode(:sbiw, %i[word_register byte], %i[S V N Z C]) do |cpu, _memory, args|
      result = (args.fetch(0).value - args.fetch(1).value) & 0xffff
      set_sreg_for_sbiw(cpu, result, args.fetch(0).value)
      args.fetch(0).value = result
    end
  end
end
