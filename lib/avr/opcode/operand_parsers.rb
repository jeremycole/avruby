module AVR
  class Opcode
    def self.twos_complement(value, bits)
      mask = 2**(bits-1)
      -(value & mask) + (value & ~mask)
    end

    def self.bit_jumble_for_lds_sts(k_in)
      k_out  = k_in & 0b00001111
      k_out |= k_in & 0b01100000 >> 1
      k_out |= k_in & 0b00010000 << 2
      k_out |= ~(k_in & 0b00010000 << 3) & 0b10000000
      k_out
    end

    # adc add and cp cpc cpse eor mov mul muls or sbc sub
    parse_operands("____ __rd dddd rrrr") do |cpu, operands|
      {
        Rd: cpu.registers[operands[:d]],
        Rr: cpu.registers[operands[:r]],
      }
    end

    # fmul fmuls fmulsu mulsu
    parse_operands("____ ____ _ddd _rrr") do |cpu, operands|
      {
        Rd: cpu.registers[operands[:d] | 0b10000],
        Rr: cpu.registers[operands[:r] | 0b10000],
      }
    end

    # asr com dec elpm inc ld lds lpm lsr neg pop ror swap
    parse_operands("____ ___d dddd ____") do |cpu, operands|
      {
        Rd: cpu.registers[operands[:d]],
      }
    end

    # lac las lat push st xch
    parse_operands("____ ___r rrrr ____") do |cpu, operands|
      {
        Rr: cpu.registers[operands[:r]],
      }
    end
    
    # bld sbrc sbrs
    parse_operands("____ ___d dddd _bbb") do |cpu, operands|
      {
        Rd: cpu.registers[operands[:d]],
        b: operands[:b],
      }
    end

    # bst
    parse_operands("____ ___r rrrr _bbb") do |cpu, operands|
      {
        Rr: cpu.registers[operands[:r]],
        b: operands[:b],
      }
    end
        
    # adiw sbiw
    parse_operands("____ ____ KKdd KKKK") do |cpu, operands|
      {
        Rd: cpu.registers.associated_word_register(cpu.registers[(operands[:d] << 1) | 0b11000]),
        K: operands[:K],
      }
    end

    # andi cpi ldi ori sbci sbr subi
    parse_operands("____ KKKK dddd KKKK") do |cpu, operands|
      {
        Rd: cpu.registers[operands[:d] | 0b10000],
        K: operands[:K],
      }
    end
  end
end