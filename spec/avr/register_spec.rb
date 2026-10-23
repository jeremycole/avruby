# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Register) do
  let(:device) { AVR::Device::Atmel_ATmega328p.new }
  let(:cpu) { device.cpu }
  let(:mem) { AVR::Memory::MemoryByteBacked.new("RegMem", 32) }

  describe "AVR::Register" do
    subject(:reg) { described_class.new(cpu, :CUSTOM) }

    it "exposes cpu and name" do
      expect(reg.cpu).to(eq(cpu))
      expect(reg.name).to(eq(:CUSTOM))
      expect(reg.to_s).to(eq("CUSTOM"))
      expect(reg.inspect).to(eq("#<AVR::Register CUSTOM>"))
    end
  end

  describe "AVR::GeneralPurposeRegister" do
    subject(:gpr) { AVR::GeneralPurposeRegister.new(cpu, 0, mem[0]) }

    it "has number and symbol name" do
      expect(gpr.number).to(eq(0))
      expect(gpr.name).to(eq(:r0))
      expect(gpr.memory_byte).to(eq(mem[0]))
    end

    it "reads and writes value to memory byte" do
      gpr.value = 0x5a
      expect(mem[0].value).to(eq(0x5a))
      expect(gpr.value).to(eq(0x5a))
    end
  end

  describe "AVR::MemoryByteRegister" do
    subject(:mbr) { AVR::MemoryByteRegister.new(cpu, :SPL, mem[1]) }

    it "exposes memory byte and delegates value" do
      expect(mbr.memory_byte).to(eq(mem[1]))
      mbr.value = 0x88
      expect(mem[1].value).to(eq(0x88))
      expect(mbr.value).to(eq(0x88))
    end
  end

  describe "AVR::MemoryByteRegisterWithNamedBits" do
    subject(:sreg) { AVR::MemoryByteRegisterWithNamedBits.new(cpu, :SREG, mem[2], [:C, :Z, :N, :V, :S, :H, :T, :I]) }

    it "defines dynamic named bit getter and setter methods" do
      sreg.C = true
      expect(sreg.C).to(be(true))
      expect(sreg.value).to(eq(0x01))

      sreg.Z = 1
      expect(sreg.Z).to(be(true))
      expect(sreg.value).to(eq(0x03))

      sreg.C = false
      expect(sreg.C).to(be(false))
      expect(sreg.value).to(eq(0x02))

      sreg.Z = 0
      expect(sreg.Z).to(be(false))
      expect(sreg.value).to(eq(0x00))
    end

    it "raises error on invalid value in bit setter" do
      expect { sreg.C = :invalid }.to(raise_error(RuntimeError, /Bad value invalid for bit C/))
    end

    it "fetches bit boolean or integer" do
      sreg.value = 0x01
      expect(sreg.fetch(:C)).to(be(true))
      expect(sreg.fetch_bit(:C)).to(eq(1))
      expect(sreg.fetch(:Z)).to(be(false))
      expect(sreg.fetch_bit(:Z)).to(eq(0))
    end

    it "generates mask for flags" do
      expect(sreg.mask_for_flags([:C, :N])).to(eq(0x05)) # C is bit 0 (1), N is bit 2 (4)
    end

    it "formats bit_values and inspect" do
      sreg.value = 0x03
      expect(sreg.bit_values).to(eq("C=1, Z=1, N=0, V=0, S=0, H=0, T=0, I=0"))
      expect(sreg.inspect).to(eq("#<AVR::MemoryByteRegisterWithNamedBits C=1, Z=1, N=0, V=0, S=0, H=0, T=0, I=0>"))
    end

    it "converts to and from hash" do
      expect(sreg.hash_for_value(0x03)).to(include(C: true, Z: true, N: false))

      mask, sum = sreg.value_for_hash(C: true, Z: false, N: 1)
      expect(mask).to(eq(0x07))
      expect(sum).to(eq(0x05))

      sreg.from_h(C: true, Z: true)
      expect(sreg.value).to(eq(0x03))

      sreg.from_h(C: false, N: true)
      expect(sreg.value).to(eq(0x06)) # C cleared, Z retained (2), N set (4)
    end

    it "resets value to 0" do
      sreg.value = 0xff
      sreg.reset
      expect(sreg.value).to(eq(0))
    end

    it "generates diff strings with diff_values" do
      diff = sreg.diff_values(0x01, 0x02) # C was 1, now 0; Z was 0, now 1
      expect(diff).to(eq("[C=1->0, Z=0->1]"))
    end
  end

  describe "AVR::RegisterPair" do
    let(:rh) { AVR::MemoryByteRegister.new(cpu, :r27, mem[27]) }
    let(:rl) { AVR::MemoryByteRegister.new(cpu, :r26, mem[26]) }
    subject(:pair) { AVR::RegisterPair.new(cpu, rh, rl, :X) }

    it "exposes h and l registers and custom name" do
      expect(pair.h).to(eq(rh))
      expect(pair.l).to(eq(rl))
      expect(pair.name).to(eq(:X))
      expect(pair.format).to(eq("%04x"))
    end

    it "reads and writes 16-bit values" do
      pair.value = 0x1234
      expect(rh.value).to(eq(0x12))
      expect(rl.value).to(eq(0x34))
      expect(pair.value).to(eq(0x1234))
    end

    it "defaults name to 'h:l' if name is omitted" do
      unnamed = AVR::RegisterPair.new(cpu, rh, rl)
      expect(unnamed.name).to(eq("r27:r26"))
    end
  end

  describe "AVR::RegisterFile" do
    subject(:rf) { cpu.registers }

    it "allows fetching registers by index" do
      expect(rf[0]).to(eq(cpu.r0))
      expect(rf.fetch(31)).to(eq(cpu.r31))
    end

    it "associates word registers for registered register pairs" do
      expect(rf.associated_word_register(cpu.r26)).to(eq(cpu.X))
      expect(rf.associated_word_register(cpu.r27)).to(eq(cpu.X))
      expect(rf.associated_word_register(cpu.r28)).to(eq(cpu.Y))
      expect(rf.associated_word_register(cpu.r29)).to(eq(cpu.Y))
      expect(rf.associated_word_register(cpu.r30)).to(eq(cpu.Z))
      expect(rf.associated_word_register(cpu.r31)).to(eq(cpu.Z))
      expect(rf.associated_word_register(cpu.r0)).to(be_nil)
    end

    it "resets all registers to 0" do
      cpu.r0.value = 42
      rf.reset
      expect(cpu.r0.value).to(eq(0))
    end

    it "provides register_values string and inspect" do
      expect(rf.register_values).to(include("r0, r1, r2"))
      expect(rf.inspect).to(include("#<AVR::RegisterFile"))
    end

    it "prints status to stdout without error" do
      expect { rf.print_status }.to(output(/r0=00.*X=0000/m).to_stdout)
    end
  end

  describe "AVR::SP" do
    subject(:sp) { cpu.sp }

    it "allows adjusting, incrementing, and decrementing the stack pointer" do
      sp.value = 0x08ff
      sp.adjust(-2)
      expect(sp.value).to(eq(0x08fd))

      sp.increment(4)
      expect(sp.value).to(eq(0x0901))

      sp.decrement(3)
      expect(sp.value).to(eq(0x08fe))
    end
  end

  describe "AVR::SREG" do
    subject(:sreg) { cpu.sreg }

    it "has all status bit accessors" do
      expect(AVR::SREG::STATUS_BITS).to(eq([:C, :Z, :N, :V, :S, :H, :T, :I]))

      sreg.C = true
      expect(sreg.C).to(be(true))
      sreg.Z = true
      expect(sreg.Z).to(be(true))
      sreg.N = true
      expect(sreg.N).to(be(true))
      sreg.V = true
      expect(sreg.V).to(be(true))
      sreg.S = true
      expect(sreg.S).to(be(true))
      sreg.H = true
      expect(sreg.H).to(be(true))
      sreg.T = true
      expect(sreg.T).to(be(true))
      sreg.I = true
      expect(sreg.I).to(be(true))

      expect(sreg.value).to(eq(0xff))
    end
  end

  describe "AVR::RegisterWithBitNumber" do
    let(:mbr) { AVR::MemoryByteRegister.new(cpu, :PORTB, mem[0]) }
    subject(:rwbn) { AVR::RegisterWithBitNumber.new(mbr, 3) }

    it "exposes register, bit_number, bit_mask, and name" do
      expect(rwbn.register).to(eq(mbr))
      expect(rwbn.bit_number).to(eq(3))
      expect(rwbn.bit_mask).to(eq(0x08))
      expect(rwbn.name).to(eq("PORTB.3"))
    end

    it "reads and sets bit value" do
      mbr.value = 0x00
      expect(rwbn.value).to(eq(0))

      rwbn.value = 1
      expect(mbr.value).to(eq(0x08))
      expect(rwbn.value).to(eq(1))
    end
  end

  describe "AVR::RegisterWithDisplacement" do
    subject(:rwd) { AVR::RegisterWithDisplacement.new(cpu.Y, 2) }

    it "exposes register, displacement, and formatted name" do
      expect(rwd.register).to(eq(cpu.Y))
      expect(rwd.displacement).to(eq(2))
      expect(rwd.name).to(eq("Y+2"))
    end

    it "delegates value and value= to register" do
      rwd.value = 0x0120
      expect(cpu.Y.value).to(eq(0x0120))
      expect(rwd.value).to(eq(0x0120))
    end
  end

  describe "AVR::RegisterWithModification" do
    it "handles none modification" do
      rwm = AVR::RegisterWithModification.new(cpu.X, :none)
      expect(rwm.register).to(eq(cpu.X))
      expect(rwm.modification).to(eq(:none))
      expect(rwm.name).to(eq("X"))

      rwm.value = 0x1234
      expect(cpu.X.value).to(eq(0x1234))
      expect(rwm.value).to(eq(0x1234))
    end

    it "handles post_increment modification" do
      rwm = AVR::RegisterWithModification.new(cpu.X, :post_increment)
      expect(rwm.modification).to(eq(:post_increment))
      expect(rwm.name).to(eq("X+"))
    end

    it "handles pre_decrement modification" do
      rwm = AVR::RegisterWithModification.new(cpu.X, :pre_decrement)
      expect(rwm.modification).to(eq(:pre_decrement))
      expect(rwm.name).to(eq("-X"))
    end
  end

  describe "AVR::RegisterWithNamedBit" do
    subject(:rwnb) { AVR::RegisterWithNamedBit.new(cpu.sreg, :C) }

    it "exposes register, named_bit, and name" do
      expect(rwnb.register).to(eq(cpu.sreg))
      expect(rwnb.named_bit).to(eq(:C))
      expect(rwnb.name).to(eq("SREG.C"))
    end

    it "reads and sets named bit value" do
      cpu.sreg.C = false
      expect(rwnb.value).to(eq(0))

      rwnb.value = 1
      expect(cpu.sreg.C).to(be(true))
      expect(rwnb.value).to(eq(1))
    end
  end
end
