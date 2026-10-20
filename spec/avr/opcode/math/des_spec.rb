# typed: false

require "shared_examples_for_opcode"

RSpec.describe(AVR::Opcode) do
  describe "des" do
    it_behaves_like "opcode", :des do
      def set_registers64(cpu, start_reg, val64)
        8.times do |i|
          cpu.registers[start_reg + i].value = (val64 >> (8 * i)) & 0xff
        end
      end

      def get_registers64(cpu, start_reg)
        val = 0
        8.times do |i|
          val |= (cpu.registers[start_reg + i].value << (8 * i))
        end
        val
      end

      let(:key) { 0x133457799BBCDFF1 }
      let(:plaintext) { 0x0123456789ABCDEF }
      let(:ciphertext) { 0x85E813540F0AB405 }

      it "encrypts standard FIPS test vector when H is 0" do
        set_registers64(cpu, 0, plaintext)
        set_registers64(cpu, 8, key)
        cpu.sreg.H = false

        16.times do |k|
          cpu.instruction(:des, AVR::Value.new(k)).execute
        end

        expect(get_registers64(cpu, 0)).to(eq(ciphertext))
        expect(get_registers64(cpu, 8)).to(eq(key))
      end

      it "decrypts standard FIPS test vector when H is 1" do
        set_registers64(cpu, 0, ciphertext)
        set_registers64(cpu, 8, key)
        cpu.sreg.H = true

        16.times do |k|
          cpu.instruction(:des, AVR::Value.new(k)).execute
        end

        expect(get_registers64(cpu, 0)).to(eq(plaintext))
        expect(get_registers64(cpu, 8)).to(eq(key))
        cpu.sreg.H = false
      end

      it "computes correct intermediate Feistel states without applying final permutation prematurely" do
        set_registers64(cpu, 0, plaintext)
        set_registers64(cpu, 8, key)
        cpu.sreg.H = false

        # Round 0: applies IP, computes Feistel round 1, outputs (L1, R1) without FP
        cpu.instruction(:des, AVR::Value.new(0)).execute
        expect(get_registers64(cpu, 0)).to(eq(0xF0AAF0AAEF4A6544))

        # Round 1: takes (L1, R1), computes Feistel round 2, outputs (L2, R2) without FP
        cpu.instruction(:des, AVR::Value.new(1)).execute
        expect(get_registers64(cpu, 0)).to(eq(0xEF4A6544CC017709))
      end

      it "executes correctly when decoded from flash memory" do
        set_registers64(cpu, 0, plaintext)
        set_registers64(cpu, 8, key)
        cpu.sreg.H = false

        # 0b1001_0100_0000_1011 is DES 0
        device.flash.set_word(0, 0b1001_0100_0000_1011)
        cpu.step

        expect(get_registers64(cpu, 0)).to(eq(0xF0AAF0AAEF4A6544))
      end

      it "does not alter SREG flags during execution" do
        set_registers64(cpu, 0, plaintext)
        set_registers64(cpu, 8, key)
        cpu.sreg.H = false
        cpu.sreg.Z = true
        cpu.sreg.C = true

        cpu.instruction(:des, AVR::Value.new(0)).execute

        expect(cpu.sreg.H).to(be(false))
        expect(cpu.sreg.Z).to(be(true))
        expect(cpu.sreg.C).to(be(true))

        cpu.sreg.Z = false
        cpu.sreg.C = false
      end

      it "correctly encrypts and decrypts with all zeros key and data" do
        set_registers64(cpu, 0, 0x0000000000000000)
        set_registers64(cpu, 8, 0x0000000000000000)
        cpu.sreg.H = false

        16.times do |k|
          cpu.instruction(:des, AVR::Value.new(k)).execute
        end

        expect(get_registers64(cpu, 0)).to(eq(0x8CA64DE9C1B123A7))

        cpu.sreg.H = true
        16.times do |k|
          cpu.instruction(:des, AVR::Value.new(k)).execute
        end

        expect(get_registers64(cpu, 0)).to(eq(0x0000000000000000))
        cpu.sreg.H = false
      end
    end
  end
end
