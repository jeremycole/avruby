# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Instruction) do
  let(:device) { AVR::Device::Atmel_ATmega328p.new }
  let(:cpu) { device.cpu }

  it "raises error for unrecognized instruction mnemonic" do
    expect do
      described_class.new(cpu, :NONEXISTENT_INSTRUCTION, [])
    end.to(raise_error(RuntimeError, /Unknown opcode NONEXISTENT_INSTRUCTION/))
  end

  describe "valid instruction" do
    subject(:inst) { described_class.new(cpu, :add, [cpu.r0, cpu.r1]) }

    it "exposes cpu, mnemonic, args, and opcode" do
      expect(inst.cpu).to(eq(cpu))
      expect(inst.mnemonic).to(eq(:add))
      expect(inst.args).to(eq([cpu.r0, cpu.r1]))
      expect(inst.opcode).to(be_a(AVR::Opcode))
    end

    it "validates instruction arguments" do
      expect(inst.valid?).to(be(true))
      expect(inst.validate).to(be(true))
    end

    it "formats string and inspect representations" do
      expect(inst.args_to_s).to(eq("r0, r1"))
      expect(inst.to_s).to(eq("add r0, r1"))
      expect(inst.inspect).to(eq("#<AVR::Instruction {add r0, r1}>"))
    end

    it "executes instruction, advancing PC and applying operation" do
      cpu.pc = 0x0000
      cpu.next_pc = 0x0000
      cpu.r0.value = 5
      cpu.r1.value = 10

      inst.execute

      expect(cpu.r0.value).to(eq(15))
      expect(cpu.pc).to(eq(1))
      expect(cpu.next_pc).to(eq(1))
    end
  end

  describe "invalid instruction" do
    # ldi requires high registers (r16..r31), passing r0 makes it invalid
    subject(:invalid_inst) { described_class.new(cpu, :ldi, [cpu.r0, AVR::Value.new(10)]) }

    it "raises OpcodeException on validation" do
      expect do
        invalid_inst.validate
      end.to(raise_error(AVR::Opcode::RegisterOutOfRange, /invalid for register/))
    end

    it "fails execution due to argument validation" do
      expect do
        invalid_inst.execute
      end.to(raise_error(AVR::Opcode::RegisterOutOfRange, /invalid for register/))
    end
  end
end
