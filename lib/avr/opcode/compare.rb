# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    # rubocop:disable Naming/MethodParameterName
    # rubocop:disable Layout/SpaceAroundOperators
    sig { params(cpu: CPU, r: Integer, rd: Integer, rr_k: Integer, mnemonic: Symbol).void }
    def self.set_sreg_for_cp_cpi_cpc(cpu, r, rd, rr_k, mnemonic)
      b7    = (1<<7)
      r7    = (r  & b7) != 0
      rd7   = (rd & b7) != 0
      rr_k7 = (rr_k & b7) != 0
      r3    = (r  & b7) != 0
      rd3   = (rd & b7) != 0
      rr_k3 = (rr_k & b7) != 0
      n     = r7
      v     = rd7 & rr_k7 & r7 | !rd7 & rr_k7 & r7
      c     = !rd7 & rr_k7 | rr_k7 & r7 | r7 & !rd7
      h     = !rd3 & rr_k3 | rr_k3 & r3 | r3 & !rd3

      z = r.zero?
      z = r.zero? ? cpu.sreg.Z : false if mnemonic == :cpc

      cpu.sreg.from_h(
        {
          H: h,
          S: n ^ v,
          V: v,
          N: n,
          Z: z,
          C: c,
        }
      )
    end
    # rubocop:enable Layout/SpaceAroundOperators
    # rubocop:enable Naming/MethodParameterName

    decode('0001 01rd dddd rrrr', :cp) do |cpu, _opcode_definition, operands|
      cpu.instruction(:cp, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:cp, %i[register register], %i[H S V N Z C]) do |cpu, _memory, args|
      result = (args.fetch(0).value - args.fetch(1).value) & 0xff
      set_sreg_for_cp_cpi_cpc(cpu, result, args.fetch(0).value, args.fetch(1).value, :cp)
    end

    decode('0000 01rd dddd rrrr', :cpc) do |cpu, _opcode_definition, operands|
      cpu.instruction(:cpc, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:cpc, %i[register register], %i[H S V N Z C]) do |cpu, _memory, args|
      result = (args.fetch(0).value - args.fetch(1).value - (cpu.sreg.C ? 1 : 0)) & 0xff
      set_sreg_for_cp_cpi_cpc(cpu, result, args.fetch(0).value, args.fetch(1).value, :cpc)
    end

    decode('0011 KKKK dddd KKKK', :cpi) do |cpu, _opcode_definition, operands|
      cpu.instruction(:cpi, operands.fetch(:Rd), operands.fetch(:K))
    end

    opcode(:cpi, %i[register byte], %i[H S V N Z C]) do |cpu, _memory, args|
      result = (args.fetch(0).value - args.fetch(1).value) & 0xff
      set_sreg_for_cp_cpi_cpc(cpu, result, args.fetch(0).value, args.fetch(1).value, :cpi)
    end
  end
end
