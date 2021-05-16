# typed: false
RSpec.describe AVR::OpcodeDecoder do
  let(:device) { AVR::Device::Atmel_ATmega328p.new }
  let(:cpu) { device.cpu }

  BASIC_OPCODES = {
    0b1001_0101_1001_1000 => "break",
    # 0b1111_0100_0000_1000 => "brbc 0, 1", # not implemented
    # 0b1111_0000_0000_1000 => "brbs 0, 1", # not implemented
    0b1001_0100_0000_1110 => "call 0x2468", # address stored in next word in flash
    0b1001_1000_0000_0000 => "cbi 0x00, 0", # cbi $00, 0?
    # 0b1001_0100_0000_1011 => "des 0x00", # not implemented
    # 0b1001_0101_0001_1001 => "eicall", # not implemented
    # 0b1001_0100_0001_1001 => "eijmp", # not implemented
    # 0b1001_0101_1101_1000 => "elpm", # not implemented
    0b1001_0101_0000_1001 => "icall",
    0b1001_0100_0000_1001 => "ijmp",
    0b1001_0100_0000_1100 => "jmp 0x2468", # address stored in next word in flash
    0b1001_0101_1100_1000 => "lpm",
    0b0000_0000_0000_0000 => "nop",
    0b1101_0000_0000_0000 => "rcall .+0",
    0b1101_1111_1111_1110 => "rcall .-4", # TODO: Is .-4 correct?
    0b1101_0000_0000_0001 => "rcall .+2",
    0b1001_0101_0000_1000 => "ret",
    0b1001_0101_0001_1000 => "reti",
    0b1100_0000_0000_0000 => "rjmp .+0",
    0b1100_1111_1111_1110 => "rjmp .-4", # TODO: Is .-4 correct?
    0b1100_0000_0000_0001 => "rjmp .+2",
    0b1001_1010_0000_0000 => "sbi 0x00, 0",
    # 0b1001_1001_0000_0000 => "sbic 0x00, 0", # not implemented
    # 0b1001_1011_0000_0000 => "sbis 0x00, 0", # not implemented
    0b1111_1100_0000_0000 => "sbrc r0.0",
    0b1111_1110_0000_0000 => "sbrs r0.0",
    0b1001_0101_1000_1000 => "sleep",
    # 0b1001_0101_1110_1000 => "spm", # not implemented
    # 0b1001_0101_1111_1000 => "spm Z+", # not implemented
    0b1001_0101_1010_1000 => "wdr",
  }

  ALL_OPCODES = BASIC_OPCODES.merge(
    opcode_for_all_rd(0b1001_0100_0000_0101, "asr"),
    opcode_for_all_rd(0b1111_1000_0000_0000, "bld", after: "0"),
    opcode_for_all_rd(0b1111_1010_0000_0000, "bst", after: "0"),
    opcode_for_all_rd(0b1001_0100_0000_0000, "com"),
    opcode_for_all_rd(0b1001_0100_0000_1010, "dec"),
    # opcode_for_all_rd(0b1001_0000_0000_0110, "elpm", after: "Z"), # not implemented
    # opcode_for_all_rd(0b1001_0000_0000_0111, "elpm", after: "Z+"), # not implemented
    opcode_for_all_rd(0b1011_0110_0000_1111, "in", after: "0x3f"),
    # opcode_for_all_rd(0b1001_0100_0000_0011, "inc"), # not implemented
    opcode_for_all_rd(0b1001_0010_0000_0101, "las"),
    opcode_for_all_rd(0b1001_0010_0000_0111, "lat"),
    opcode_for_all_rd(0b1001_0000_0000_1100, "ld", after: "X"),
    opcode_for_all_rd(0b1001_0000_0000_1101, "ld", after: "X+"),
    opcode_for_all_rd(0b1001_0000_0000_1110, "ld", after: "-X"),
    opcode_for_all_rd(0b1000_0000_0000_1000, "ld", after: "Y"),
    opcode_for_all_rd(0b1001_0000_0000_1001, "ld", after: "Y+"),
    opcode_for_all_rd(0b1001_0000_0000_1010, "ld", after: "-Y"),
    opcode_for_all_rd(0b1000_0000_0000_0000, "ld", after: "Z"),
    opcode_for_all_rd(0b1001_0000_0000_0001, "ld", after: "Z+"),
    opcode_for_all_rd(0b1001_0000_0000_0010, "ld", after: "-Z"),
    opcode_for_all_rd(0b1010_1100_0000_1111, "ldd", after: "Y+63"),
    opcode_for_all_rd(0b1010_1100_0000_0111, "ldd", after: "Z+63"),
    opcode_for_all_rd(0b1001_0000_0000_0000, "lds", after: "0x1234"), # address from next word in flash
    opcode_for_all_rd(0b1001_0000_0000_0100, "lpm", after: "Z"),
    opcode_for_all_rd(0b1001_0000_0000_0101, "lpm", after: "Z+"),
    opcode_for_all_rd(0b1001_0100_0000_0110, "lsr"),
    # opcode_for_all_rd(0b1001_0100_0000_0001, "neg"), # not implemented
    opcode_for_all_rd(0b1011_1110_0000_1111, "out", before: "0x3f"),
    opcode_for_all_rd(0b1001_0000_0000_1111, "pop"),
    opcode_for_all_rd(0b1001_0010_0000_1111, "push"),
    opcode_for_all_rd(0b1001_0100_0000_0111, "ror"),
    opcode_for_all_rd(0b1001_0010_0000_1100, "st", before: "X"),
    opcode_for_all_rd(0b1001_0010_0000_1101, "st", before: "X+"),
    opcode_for_all_rd(0b1001_0010_0000_1110, "st", before: "-X"),
    opcode_for_all_rd(0b1000_0010_0000_1000, "st", before: "Y"),
    opcode_for_all_rd(0b1001_0010_0000_1001, "st", before: "Y+"),
    opcode_for_all_rd(0b1001_0010_0000_1010, "st", before: "-Y"),
    opcode_for_all_rd(0b1000_0010_0000_0000, "st", before: "Z"),
    opcode_for_all_rd(0b1001_0010_0000_0001, "st", before: "Z+"),
    opcode_for_all_rd(0b1001_0010_0000_0010, "st", before: "-Z"),
    opcode_for_all_rd(0b1010_1110_0000_1111, "std", before: "Y+63"),
    opcode_for_all_rd(0b1010_1110_0000_0111, "std", before: "Z+63"),
    opcode_for_all_rd(0b1001_0010_0000_0000, "sts", before: "0x1234"), # address from next word in flash
    opcode_for_all_rd(0b1001_0100_0000_0010, "swap"),
    opcode_for_all_rd(0b1001_0010_0000_0100, "xch"),

    opcode_for_all_high_rd(0b0111_1111_0000_1111, "andi", after: "0xff"),
    opcode_for_all_high_rd(0b0011_1111_0000_1111, "cpi", after: "0xff"),
    opcode_for_all_high_rd(0b1110_1111_0000_1111, "ldi", after: "0xff"),
    opcode_for_all_high_rd(0b1010_0111_0000_1111, "lds", after: "0x00ff"),
    opcode_for_all_high_rd(0b0110_1111_0000_1111, "ori", after: "0xff"),
    opcode_for_all_high_rd(0b0100_1111_0000_1111, "sbci", after: "0xff"),
    #opcode_for_all_rd(0b1010_1000_0000_0000, "sts", before: "0x00ff"), # BUG: Decoding conflict with ldd.
    opcode_for_all_high_rd(0b0101_1111_0000_1111, "subi", after: "0xff"),

    opcode_for_all_rd_rr_pairs(0b0000_1100_0000_0000, "add", alternate: "lsl"),
    opcode_for_all_rd_rr_pairs(0b0001_1100_0000_0000, "adc", alternate: "rol"),
    opcode_for_all_rd_rr_pairs(0b0010_0000_0000_0000, "and", alternate: "tst"),
    opcode_for_all_rd_rr_pairs(0b0001_0100_0000_0000, "cp"),
    opcode_for_all_rd_rr_pairs(0b0000_0100_0000_0000, "cpc"),
    opcode_for_all_rd_rr_pairs(0b0001_0000_0000_0000, "cpse"),
    opcode_for_all_rd_rr_pairs(0b0010_0100_0000_0000, "eor"),
    # opcode_for_all_rd_rr_pairs(0b0000_0011_0000_1000, "fmul", min: 16, max: 23), # not implemented
    # opcode_for_all_rd_rr_pairs(0b0000_0011_1000_0000, "fmuls", min: 16, max: 23), # not implemented
    # opcode_for_all_rd_rr_pairs(0b0000_0011_1000_1000, "fmulsu", min: 16, max: 23), # not implemented
    opcode_for_all_rd_rr_pairs(0b0010_1100_0000_0000, "mov"),
    opcode_for_all_rd_rr_pairs(0b1001_1100_0000_0000, "mul"),
    # opcode_for_all_rd_rr_pairs(0b0000_0010_0000_1111, "muls", min: 16, max: 31), # not implemented
    # opcode_for_all_rd_rr_pairs(0b0000_0011_0000_0000, "mulsu", min: 16, max: 23), # not implemented
    opcode_for_all_rd_rr_pairs(0b0010_1000_0000_0000, "or"),
    opcode_for_all_rd_rr_pairs(0b0000_1000_0000_0000, "sbc"),
    opcode_for_all_rd_rr_pairs(0b0001_1000_0000_0000, "sub"),

    opcode_for_all_word_registers(0b1001_0110_1100_1111, "adiw", after: "0x3f"),
    opcode_for_all_word_registers(0b1001_0111_1100_1111, "sbiw", after: "0x3f"),

    opcode_for_all_word_register_pairs(0b0000_0001_0000_0000, "movw"),

    opcode_for_all_sreg_flags(0b1001_0100_0000_1000, "bset"),
    opcode_for_all_sreg_flags(0b1001_0100_1000_1000, "bclr"),
  )

  describe "all opcode decodes", opcode_decoder: :all do
    ALL_OPCODES.each do |word, code|
      binary = format("%016b", word).each_char.each_slice(4).map(&:join).join("_")
      it "can decode 0b#{binary} = #{code}" do
        device.flash.set_word(0, word)
        device.flash.set_word(1, 0x1234)
        expect(cpu.decode.to_s).to eq(code)
      end
    end
  end

  describe "sample opcode decodes", opcode_decoder: :sample do
    ALL_OPCODES.to_a.sample(100).each do |word, code|
      binary = format("%016b", word).each_char.each_slice(4).map(&:join).join("_")
      it "(sample) can decode 0b#{binary} = #{code}" do
        device.flash.set_word(0, word)
        device.flash.set_word(1, 0x1234)
        expect(cpu.decode.to_s).to eq(code)
      end
    end
  end
end
