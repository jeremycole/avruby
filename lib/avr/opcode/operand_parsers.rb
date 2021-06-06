# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    sig { params(value: Integer, bits: Integer).returns(Integer) }
    def self.from_twos_complement(value, bits)
      mask = (2**(bits - 1)).to_i
      -(value & mask) + (value & ~mask)
    end

    sig { params(value: Integer, bits: Integer).returns(Integer) }
    def self.to_twos_complement(value, bits)
      return value unless value.negative?
      ((value.magnitude) ^ ((1 << bits) - 1)) + 1
    end

    sig { params(k_in: Integer).returns(Integer) }
    def self.bit_jumble_for_lds_sts(k_in)
      k_out  = k_in & 0b00001111
      k_out |= (k_in & 0b01100000) >> 1
      k_out |= (k_in & 0b00010000) << 2
      k_out |= ~((k_in & 0b00010000) << 3) & 0x7f
      k_out
    end

    # adc add and cp cpc cpse eor mov mul muls or sbc sub
    parse_operands("____ __rd dddd rrrr") do |cpu, operands|
      {
        Rd: cpu.registers.fetch(operands.fetch(:d).value),
        Rr: cpu.registers.fetch(operands.fetch(:r).value),
      }
    end

    # muls
    parse_operands("____ ____ dddd rrrr") do |cpu, operands|
      {
        Rd: cpu.registers.fetch(operands.fetch(:d).value + 16),
        Rr: cpu.registers.fetch(operands.fetch(:r).value + 16),
      }
    end

    # fmul fmuls fmulsu mulsu
    parse_operands("____ ____ _ddd _rrr") do |cpu, operands|
      {
        Rd: cpu.registers.fetch(operands.fetch(:d).value | 0b10000),
        Rr: cpu.registers.fetch(operands.fetch(:r).value | 0b10000),
      }
    end

    # movw
    parse_operands("____ ____ DDDD RRRR") do |cpu, operands|
      d = operands.fetch(:D).value
      r = operands.fetch(:R).value
      {
        Rd: RegisterPair.new(cpu, cpu.registers.fetch((d << 1) + 1), cpu.registers.fetch(d << 1)),
        Rr: RegisterPair.new(cpu, cpu.registers.fetch((r << 1) + 1), cpu.registers.fetch(r << 1)),
      }
    end

    # asr com dec elpm inc ld lds lpm lsr neg pop ror swap
    parse_operands("____ ___d dddd ____") do |cpu, operands|
      {
        Rd: cpu.registers.fetch(operands.fetch(:d).value),
      }
    end

    # lac las lat push st xch
    parse_operands("____ ___r rrrr ____") do |cpu, operands|
      {
        Rr: cpu.registers.fetch(operands.fetch(:r).value),
      }
    end

    # sbrc sbrs
    parse_operands("____ ___r rrrr _bbb") do |cpu, operands|
      {
        Rr: cpu.registers.fetch(operands.fetch(:r).value),
        b:  Value.new(operands.fetch(:b).value),
      }
    end

    # adiw sbiw
    parse_operands("____ ____ KKdd KKKK") do |cpu, operands|
      register_base = (operands.fetch(:d).value << 1) | 0b11000
      {
        Rd: RegisterPair.new(
          cpu,
          cpu.registers.fetch(register_base + 1),
          cpu.registers.fetch(register_base)
        ),
        K:  Value.new(operands.fetch(:K).value),
      }
    end

    # andi cpi ldi ori sbci sbr subi
    parse_operands("____ KKKK dddd KKKK") do |cpu, operands|
      {
        Rd: cpu.registers.fetch(operands.fetch(:d).value | 0b10000),
        K:  Value.new(operands.fetch(:K).value),
      }
    end

    # cbi sbi sbic sbis
    parse_operands("____ ____ AAAA Abbb") do |_cpu, operands|
      {
        A: operands.fetch(:A),
        b: operands.fetch(:b),
      }
    end
  end
end
