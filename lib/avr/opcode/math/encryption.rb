# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    # Initial Permutation (IP): Reorders the 64-bit input block before Feistel rounds (FIPS 46).
    DES_IP = T.let([
                     58, 50, 42, 34, 26, 18, 10, 2,
                     60, 52, 44, 36, 28, 20, 12, 4,
                     62, 54, 46, 38, 30, 22, 14, 6,
                     64, 56, 48, 40, 32, 24, 16, 8,
                     57, 49, 41, 33, 25, 17, 9, 1,
                     59, 51, 43, 35, 27, 19, 11, 3,
                     61, 53, 45, 37, 29, 21, 13, 5,
                     63, 55, 47, 39, 31, 23, 15, 7,
                   ], T::Array[Integer])

    # Final Permutation (FP / IP^-1): Inverse of Initial Permutation, applied to the 64-bit block after the final round.
    DES_FP = T.let([
                     40, 8, 48, 16, 56, 24, 64, 32,
                     39, 7, 47, 15, 55, 23, 63, 31,
                     38, 6, 46, 14, 54, 22, 62, 30,
                     37, 5, 45, 13, 53, 21, 61, 29,
                     36, 4, 44, 12, 52, 20, 60, 28,
                     35, 3, 43, 11, 51, 19, 59, 27,
                     34, 2, 42, 10, 50, 18, 58, 26,
                     33, 1, 41, 9, 49, 17, 57, 25,
                   ], T::Array[Integer])

    # Permuted Choice 1, Left Half (PC-1 C): Selects and permutes 28 bits (C0) from 64-bit key (ignoring parity bits).
    DES_PC1_C = T.let([
                        57, 49, 41, 33, 25, 17, 9,
                        1, 58, 50, 42, 34, 26, 18,
                        10, 2, 59, 51, 43, 35, 27,
                        19, 11, 3, 60, 52, 44, 36,
                      ], T::Array[Integer])

    # Permuted Choice 1, Right Half (PC-1 D): Selects and permutes 28 bits (D0) from 64-bit key (ignoring parity bits).
    DES_PC1_D = T.let([
                        63, 55, 47, 39, 31, 23, 15,
                        7, 62, 54, 46, 38, 30, 22,
                        14, 6, 61, 53, 45, 37, 29,
                        21, 13, 5, 28, 20, 12, 4,
                      ], T::Array[Integer])

    # Permuted Choice 2 (PC-2): Compresses and permutes the combined 56-bit CD key state into a 48-bit round subkey.
    DES_PC2 = T.let([
                      14, 17, 11, 24, 1, 5,
                      3, 28, 15, 6, 21, 10,
                      23, 19, 12, 4, 26, 8,
                      16, 7, 27, 20, 13, 2,
                      41, 52, 31, 37, 47, 55,
                      30, 40, 51, 45, 33, 48,
                      44, 49, 39, 56, 34, 53,
                      46, 42, 50, 36, 29, 32,
                    ], T::Array[Integer])

    # Expansion Permutation (E-box): Expands 32-bit right half (R) to 48 bits to match subkey size in Feistel rounds.
    DES_E = T.let([
                    32, 1, 2, 3, 4, 5,
                    4, 5, 6, 7, 8, 9,
                    8, 9, 10, 11, 12, 13,
                    12, 13, 14, 15, 16, 17,
                    16, 17, 18, 19, 20, 21,
                    20, 21, 22, 23, 24, 25,
                    24, 25, 26, 27, 28, 29,
                    28, 29, 30, 31, 32, 1,
                  ], T::Array[Integer])

    # Permutation (P-box): Permutes the 32-bit output resulting from S-box substitution in the Feistel function.
    DES_P = T.let([
                    16, 7, 20, 21,
                    29, 12, 28, 17,
                    1, 15, 23, 26,
                    5, 18, 31, 10,
                    2, 8, 24, 14,
                    32, 27, 3, 9,
                    19, 13, 30, 6,
                    22, 11, 4, 25,
                  ], T::Array[Integer])

    # Substitution Boxes (S1–S8): Non-linear lookup tables mapping 6-bit inputs to 4-bit outputs in Feistel rounds.
    DES_S_BOXES = T.let([
                          [
                            [14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7],
                            [0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8],
                            [4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0],
                            [15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13],
                          ],
                          [
                            [15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10],
                            [3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5],
                            [0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15],
                            [13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9],
                          ],
                          [
                            [10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8],
                            [13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1],
                            [13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7],
                            [1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12],
                          ],
                          [
                            [7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15],
                            [13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9],
                            [10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4],
                            [3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14],
                          ],
                          [
                            [2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9],
                            [14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6],
                            [4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14],
                            [11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3],
                          ],
                          [
                            [12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11],
                            [10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8],
                            [9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6],
                            [4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13],
                          ],
                          [
                            [4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1],
                            [13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6],
                            [1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2],
                            [6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12],
                          ],
                          [
                            [13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7],
                            [1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2],
                            [7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8],
                            [2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11],
                          ],
                        ], T::Array[T::Array[T::Array[Integer]]])

    # Left Shift Schedule: Number of bits to rotate left C and D halves per round (0..15) in key generation.
    DES_SHIFTS = T.let([1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1], T::Array[Integer])

    sig { params(val: Integer, table: T::Array[Integer], in_bits: Integer).returns(Integer) }
    def self.des_permute(val, table, in_bits)
      res = 0
      table.each do |pos|
        bit = (val >> (in_bits - pos)) & 1
        res = (res << 1) | bit
      end
      res
    end

    sig { params(key64: Integer).returns(T::Array[Integer]) }
    def self.des_generate_subkeys(key64)
      c = des_permute(key64, DES_PC1_C, 64)
      d = des_permute(key64, DES_PC1_D, 64)
      subkeys = []
      16.times do |i|
        shift = T.must(DES_SHIFTS[i])
        c = ((c << shift) | (c >> (28 - shift))) & 0x0fffffff
        d = ((d << shift) | (d >> (28 - shift))) & 0x0fffffff
        cd = (c << 28) | d
        subkeys << des_permute(cd, DES_PC2, 56)
      end
      subkeys
    end

    sig { params(r: Integer, subkey: Integer).returns(Integer) }
    def self.des_feistel(r, subkey)
      er = des_permute(r, DES_E, 32)
      b = er ^ subkey
      s_out = 0
      8.times do |i|
        chunk = (b >> (42 - (6 * i))) & 0x3f
        row = ((chunk >> 4) & 2) | (chunk & 1)
        col = (chunk >> 1) & 0x0f
        s_box = T.must(DES_S_BOXES[i])
        s_row = T.must(s_box[row])
        s_val = T.must(s_row[col])
        s_out = (s_out << 4) | s_val
      end
      des_permute(s_out, DES_P, 32)
    end

    sig { params(data64: Integer, key64: Integer, k: Integer, decrypt: T::Boolean).returns(Integer) }
    def self.des_round(data64, key64, k, decrypt)
      subkeys = des_generate_subkeys(key64)
      subkey = decrypt ? T.must(subkeys[15 - k]) : T.must(subkeys[k])

      ip_val = des_permute(data64, DES_IP, 64)
      l = (ip_val >> 32) & 0xffffffff
      r = ip_val & 0xffffffff

      f_val = des_feistel(r, subkey)
      next_l = r
      next_r = l ^ f_val

      combined = k == 15 ? ((next_r << 32) | next_l) : ((next_l << 32) | next_r)
      des_permute(combined, DES_FP, 64)
    end

    parse_operands("____ ____ KKKK ____") do |_cpu, operands|
      {
        k: operands.fetch(:K),
      }
    end

    decode("1001 0100 KKKK 1011", :des) do |cpu, _opcode_definition, operands|
      cpu.instruction(:des, operands.fetch(:k))
    end

    opcode(:des, [Arg.byte]) do |cpu, _memory, args|
      k = args.fetch(0).value

      data64 = 0
      8.times do |i|
        reg = cpu.registers[i]
        data64 |= (reg.value << (8 * i))
      end

      key64 = 0
      8.times do |i|
        reg = cpu.registers[8 + i]
        key64 |= (reg.value << (8 * i))
      end

      decrypt = cpu.sreg.H
      result64 = des_round(data64, key64, k, decrypt)

      8.times do |i|
        reg = cpu.registers[i]
        reg.value = (result64 >> (8 * i)) & 0xff
      end
    end
  end
end
