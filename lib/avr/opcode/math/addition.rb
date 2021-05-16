# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    # rubocop:disable Naming/MethodParameterName
    sig { params(cpu: CPU, r: Integer, rd: Integer).void }
    def self.set_sreg_for_inc(cpu, r, rd)
      n = (r & (1 << 7)) != 0
      v = (rd == 0x7f)

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

    decode('1001 101d dddd 0011', :inc) do |cpu, _opcode_definition, operands|
      cpu.instruction(:inc, operands.fetch(:Rd))
    end

    opcode(:inc, %i[register], %i[S V N Z]) do |cpu, _memory, args|
      result = (args.fetch(0).value + 1) & 0xff
      set_sreg_for_inc(cpu, result, args.fetch(0).value)
      args.fetch(0).value = result
    end

    # rubocop:disable Naming/MethodParameterName
    sig { params(cpu: CPU, r: Integer, rd: Integer, rr: Integer).void }
    def self.set_sreg_for_add_adc(cpu, r, rd, rr)
      b7  = (1 << 7)
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

    decode('0000 11rd dddd rrrr', :add) do |cpu, _opcode_definition, operands|
      if operands.fetch(:Rd) == operands.fetch(:Rr)
        cpu.instruction(:lsl, operands.fetch(:Rd))
      else
        cpu.instruction(:add, operands.fetch(:Rd), operands.fetch(:Rr))
      end
    end

    opcode(:add, %i[register register], %i[H S V N Z C]) do |cpu, _memory, args|
      result = (args.fetch(0).value + args.fetch(1).value) & 0xff
      set_sreg_for_add_adc(cpu, result, args.fetch(0).value, args.fetch(1).value)
      args.fetch(0).value = result
    end

    decode('0001 11rd dddd rrrr', :adc) do |cpu, _opcode_definition, operands|
      if operands.fetch(:Rd) == operands.fetch(:Rr)
        cpu.instruction(:rol, operands.fetch(:Rd))
      else
        cpu.instruction(:adc, operands.fetch(:Rd), operands.fetch(:Rr))
      end
    end

    opcode(:adc, %i[register register], %i[H S V N Z C]) do |cpu, _memory, args|
      result = (args.fetch(0).value + args.fetch(1).value + (cpu.sreg.C ? 1 : 0)) & 0xff
      set_sreg_for_add_adc(cpu, result, args.fetch(0).value, args.fetch(1).value)
      args.fetch(0).value = result
    end

    # rubocop:disable Naming/MethodParameterName
    # rubocop:disable Layout/SpaceAroundOperators
    sig { params(cpu: CPU, r: Integer, rd: Integer).void }
    def self.set_sreg_for_adiw(cpu, r, rd)
      b15  = (1 << 15)
      b7   = (1 << 7)
      rdh7 = (rd & b7) != 0
      r15  = (r & b15) != 0
      v   = !rdh7 & r15
      n   = r15
      c   = !r15 & rdh7

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

    decode('1001 0110 KKdd KKKK', :adiw) do |cpu, _opcode_definition, operands|
      cpu.instruction(:adiw, operands.fetch(:Rd), operands.fetch(:K))
    end

    opcode(:adiw, %i[word_register byte], %i[S V N Z C]) do |cpu, _memory, args|
      result = (args.fetch(0).value + args.fetch(1).value) & 0xffff
      set_sreg_for_adiw(cpu, result, args.fetch(0).value)
      args.fetch(0).value = result
    end
  end
end
