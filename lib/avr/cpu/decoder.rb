module AVR
  class Decoder
    attr_reader :cpu
    attr_reader :memory

    def initialize(cpu, memory)
      @cpu = cpu
      @memory = memory
    end

    def instruction(offset, mnemonic, *args)
      #puts "#{offset} decoded #{mnemonic} with args #{args}"
      AVR::Instruction.new(cpu, memory, offset, mnemonic, *args)
    end

    def extract_bits(value, offset, nbits)
      (value & (((2 ** nbits) - 1) << offset)) >> offset
    end

    def extract_pc(word)
      (extract_bits(word, 20, 5) << 17) | extract_bits(word, 0, 17)
    end

    def extract_a_b(word)
      a = extract_bits(word, 3, 5)
      b = extract_bits(word, 0, 3)
      [a, b]
    end

    def extract_rdw_rrw(word)
      rdwl = extract_bits(word, 4, 4) << 1
      rrwl = extract_bits(word, 0, 4) << 1
      [
        cpu.registers.associated_word_register(cpu.registers[rdwl]),
        cpu.registers.associated_word_register(cpu.registers[rrwl]),
      ]
    end

    def extract_rd_n(word)
      rd = extract_bits(word, 4, 5)
      n = extract_bits(word, 0, 4) | (extract_bits(word, 9, 1) << 4)
      [cpu.registers[rd], n]
    end

    def extract_rd_k7(word)
      rd = extract_bits(word, 4, 4) | 0b10000
      (extract_bits(word, 8, 3) << 4)
      # The bit order for k is scrambled: !8, 8, 10, 9, 3, 2, 1 0
      k3210 = extract_bits(word, 0, 4)
      k4    = extract_bits(word, 9, 1)
      k5    = extract_bits(word, 10, 1)
      k6    = extract_bits(word, 8, 1)
      k7    = ~k6 & 0x01
      k     = (k7 << 7) | (k6 << 6) | (k5 << 5) | (k4 << 4) | k3210
      [cpu.registers[rd], k]
    end

    def extract_rd_k(word)
      rd = extract_bits(word, 4, 4) | 0b10000
      k = (extract_bits(word, 8, 4) << 4) | extract_bits(word, 0, 4)
      [cpu.registers[rd], k]
    end

    def extract_rdw_k(word)
      rdwl = (extract_bits(word, 4, 2) << 1) | 0b11000
      k = (extract_bits(word, 6, 2) << 4) | extract_bits(word, 0, 4)
      [cpu.registers.associated_word_register(cpu.registers[rdwl]), k]
    end

    def twos_complement(value, bits)
      mask = 2**(bits-1)
      -(value & mask) + (value & ~mask)
    end

    def extract_s_k(word)
      s = extract_bits(word, 0, 3)
      k = twos_complement(extract_bits(word, 3, 7), 7)
      [s, k]
    end

    OPCODES_NO_ARGS = {
      0b0000_0000_0000_0000 => :nop,
      0b1001_0100_0000_1001 => :ijmp,
      0b1001_0100_0001_1001 => :eijmp,
      0b1001_0101_0000_1000 => :ret,
      0b1001_0101_0000_1001 => :icall,
      0b1001_0101_0001_1000 => :reti,
      0b1001_0101_0001_1001 => :eicall,
      0b1001_0101_1000_1000 => :sleep,
      0b1001_0101_1001_1000 => :break,
      0b1001_0101_1010_1000 => :wdr,
      0b1001_0101_1100_1000 => :lpm,
      0b1001_0101_1110_1000 => :spm,
      0b1001_0101_1111_1000 => :spm, # Needs Z+
    }

    OPCODES_SREG = {
      0b1001_0100_0 => :bset, # also sec, sez, sen, sev, ses, seh, set, sei
      0b1001_0100_1 => :bclr, # also clc, clz, cln, clv, cls, clh, clt, cli
    }

    OPCODES_RDw_RRw = {
      0b0000_0001 => :movw,
    }

    OPCODES_A_B = {
      0b1001_1000 => :cbi,
      0b1001_1010 => :sbi,
    }

    OPCODES_RDw_K = {
      0b1001_0110 => :adiw,
      0b1001_0111 => :sbiw,
    }

    OPMODES_PC = {
      0b1001_010 => {
        0b110 => :jmp,
        0b111 => :call,
      }
    }

    OPCODES_RD_N = {
      0b0000_01 => :cpc,
      0b0000_10 => :sbc,
      0b0000_11 => :add,
      0b0001_00 => :cpse,
      0b0001_01 => :cp,
      0b0001_10 => :sub,
      0b0001_11 => :adc,
      0b0010_00 => :and,
      0b0010_01 => :eor,
      0b0010_10 => :or,
      0b0010_11 => :mov,
      0b1000_00 => {
        0b00000 => [:ld, :Z],
        0b01000 => [:ld, :Y],
      },
      0b1001_00 => {
        0b00000 => :lds,
        0b00001 => [:ld, :Z, :post_increment],
        0b00010 => [:ld, :Z, :pre_decrement],
        0b00100 => [:lpm, :Z],
        0b00101 => [:lpm, :Z, :post_increment],
        0b01001 => [:ld, :Y, :post_increment],
        0b01010 => [:ld, :Y, :pre_decrement],
        0b01100 => [:ld, :X],
        0b01101 => [:ld, :X, :post_increment],
        0b01110 => [:ld, :X, :pre_decrement],
        0b01111 => :pop,
        0b10000 => :sts,
        0b10100 => :xch,
        0b10101 => :las,
        0b10110 => :lac,
        0b10111 => :lat,
        0b11100 => [:st, :X],
        0b11101 => [:st, :X, :post_increment],
        0b11110 => [:st, :X, :pre_decrement],
        0b11111 => :push,
      },
      0b1001_01 => {
        0b00000 => :com,
        0b00001 => :neg,
        0b00010 => :swap,
        0b00011 => :inc,
        0b00101 => :asr,
        0b00110 => :lsr,
        0b01010 => :dec,
      },
      0b1001_11 => :mul,
    }

    OPCODES_BRANCH = {
      0b1111_00 => :brbs, # also brcs, breq, brmi, brvs, brlt, brhs, brts, brie
      0b1111_01 => :brbc, # also brcc, brne, brpl, brvc, brge, brhc, brtc, brid
    }

    def extract_a_r(word)
      a = (extract_bits(word, 9, 2) << 4) | extract_bits(word, 0, 4)
      r = extract_bits(word, 4, 5)
      [a, cpu.registers[r]]
    end

    OPCODES_A_R = {
      0b1011_0 => :in,
      0b1011_1 => :out,
    }

    OPCODES_RD_K7 = {
      0b1010_0 => :lds,
      0b1010_1 => :sts,
    }

    OPCODES_RD_K = {
      0b0011 => :cpi,
      0b0100 => :sbci,
      0b0101 => :subi,
      0b0110 => :ori, # also sbr
      0b0111 => :andi,
      0b1110 => :ldi,
    }

    OPCODES_K = {
      0b1100 => :rjmp,
      0b1101 => :rcall,
    }

    def decode
      offset = cpu.pc
      word = cpu.fetch

      opcode = OPCODES_NO_ARGS[word]
      return instruction(offset, opcode) if opcode

      msb9 = extract_bits(word, 7, 9)
      lsb4 = extract_bits(word, 0, 4)
      opcode = OPCODES_SREG[msb9]
      if opcode && lsb4 == 0b1000
        s = extract_bits(word, 4, 3)
        return instruction(offset, opcode, AVR::SREG::STATUS_BITS[s])
      end

      msb8 = extract_bits(word, 8, 8)
      opcode = OPCODES_A_B[msb8]
      if opcode
        a, b = extract_a_b(word)
        return instruction(offset, opcode, a, b)
      end

      opcode = OPCODES_RDw_K[msb8]
      if opcode
        rd, k = extract_rdw_k(word)
        return instruction(offset, opcode, rd, k)
      end

      opcode = OPCODES_RDw_RRw[msb8]
      if opcode
        rdw, rrw = extract_rdw_rrw(word)
        return instruction(offset, opcode, rdw, rrw)
      end

      msb7 = extract_bits(word, 9, 7)
      opmode = OPMODES_PC[msb7]
      if opmode
        nnn3 = extract_bits(word, 1, 3)
        pc = extract_pc((word<< 16) | cpu.fetch)
        return instruction(offset, opmode[nnn3], pc)
      end

      msb6 = extract_bits(word, 10, 6)
      opcode = OPCODES_RD_N[msb6]
      if opcode
        rd, n = extract_rd_n(word)
        if opcode.is_a?(Hash)
          case
          when opcode[n].is_a?(Symbol) # XXX Rd
            case opcode[n]
            when :lds
              address = cpu.fetch
              return instruction(offset, opcode[n], rd, address)
            when :sts
              address = cpu.fetch
              return instruction(offset, opcode[n], address, rd)
            end
            return instruction(offset, opcode[n], rd)
          when opcode[n].is_a?(Array) && opcode[n].size >= 2 # XXX Rd, [-]{X,Y,Z}[+]
            word_register = cpu.send(opcode[n][1])
            modifying_word_register = opcode[n][2] ? [word_register, opcode[n][2]] : word_register
            case opcode[n][0]
            when :lpm
              return instruction(offset, opcode[n][0], rd, modifying_word_register)
            when :st
              return instruction(offset, opcode[n][0], modifying_word_register, rd)
            end
          end
        end
        return instruction(offset, :lsl, rd) if opcode == :add && rd == n
        return instruction(offset, :rol, rd) if opcode == :adc && rd == n
        return instruction(offset, opcode, rd, cpu.registers[n]) # n = Rr
      end

      opcode = OPCODES_BRANCH[msb6]
      if opcode
        s, k = extract_s_k(word)
        return instruction(offset, opcode, AVR::SREG::STATUS_BITS[s], k)
      end

      msb5 = extract_bits(word, 11, 5)
      opcode = OPCODES_A_R[msb5]
      if opcode
        a, r = extract_a_r(word)
        return instruction(offset, opcode, r, a) if opcode == :in
        return instruction(offset, opcode, a, r) if opcode == :out
      end

      opcode = OPCODES_RD_K7[msb5]
      if opcode
        rd, k = extract_rd_k7(word)
        return instruction(offset, opcode, rd, k) if opcode == :lds
        return instruction(offset, opcode, k, rd) if opcode == :sts
      end

      msb4 = extract_bits(word, 12, 4)
      opcode = OPCODES_RD_K[msb4]
      if opcode
        rd, k = extract_rd_k(word)
        return instruction(offset, opcode, rd, k)
      end

      opcode = OPCODES_K[msb4]
      if opcode
        k = twos_complement(extract_bits(word, 0, 12), 12)
        return instruction(offset, opcode, k)
      end

      raise "Unable to decode #{word.to_s(16)}"
    end
    
  end
end