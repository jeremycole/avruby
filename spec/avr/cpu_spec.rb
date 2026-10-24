# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::CPU) do
  let(:device) { AVR::Device::Atmel_ATmega328p.new }
  subject(:cpu) { device.cpu }

  it "exposes architecture components" do
    expect(cpu.device).to(eq(device))
    expect(cpu.register_memory).to(be_a(AVR::Memory::MemoryByteBacked))
    expect(cpu.io_register_memory).to(be_a(AVR::Memory::MemoryByteBacked))
    expect(cpu.ext_io_register_memory).to(be_a(AVR::Memory::MemoryByteBacked))
    expect(cpu.sram).to(be_a(AVR::Memory::SRAM))
    expect(cpu.data_address_space).to(be_a(AVR::Memory::AddressSpace))
    expect(cpu.fuses).to(eq(device.fuses))
    expect(cpu.sreg).to(be_a(AVR::SREG))
    expect(cpu.sp).to(be_a(AVR::SP))
    expect(cpu.decoder).to(be_a(AVR::OpcodeDecoder))
    expect(cpu.clock).to(be_a(AVR::Clock))
    expect(cpu.clock.ticks).to(eq(0))
  end

  it "supports register accessors and word register pairs" do
    cpu.r0 = 0x12
    cpu.r1 = 0x34
    expect(cpu.r0.value).to(eq(0x12))
    expect(cpu.r1.value).to(eq(0x34))
    expect(cpu.r1r0.value).to(eq(0x3412))

    cpu.X = 0xabcd
    expect(cpu.r27.value).to(eq(0xab))
    expect(cpu.r26.value).to(eq(0xcd))
    expect(cpu.X.value).to(eq(0xabcd))
  end

  describe "#reset and #reset_to_clean_state" do
    it "resets registers, PC, and stack pointer" do
      cpu.r0 = 0x99
      cpu.pc.value = 0x0100
      cpu.next_pc.value = 0x0100
      cpu.sp.value = 0x0100

      cpu.reset_to_clean_state

      expect(cpu.r0.value).to(eq(0x00))
      expect(cpu.pc).to(eq(device.reset_address))
      expect(cpu.next_pc).to(eq(device.reset_address))
      expect(cpu.sp.value).to(eq(device.sram_size + 0x0100 - 1))
    end
  end

  describe "#fetch" do
    it "reads word at next_pc and increments next_pc" do
      device.flash.set_word(0, 0x1234)
      cpu.pc.value = 0
      cpu.next_pc.value = 0

      word = cpu.fetch
      expect(word).to(eq(0x1234))
      expect(cpu.next_pc).to(eq(1))
      expect(cpu.pc).to(eq(0))
    end
  end

  describe "#instruction" do
    it "constructs an Instruction bound to this CPU" do
      inst = cpu.instruction(:nop)
      expect(inst).to(be_a(AVR::Instruction))
      expect(inst.mnemonic).to(eq(:nop))
    end
  end

  describe "#decode and #peek" do
    before do
      # nop instruction: 0x0000
      device.flash.set_word(0, 0x0000)
      cpu.pc.value = 0
      cpu.next_pc.value = 0
    end

    it "decodes instruction at pc and advances next_pc" do
      inst = cpu.decode
      expect(inst.mnemonic).to(eq(:nop))
      expect(cpu.next_pc).to(eq(1))
    end

    it "peeks at instruction without altering pc or next_pc" do
      inst = cpu.peek
      expect(inst.mnemonic).to(eq(:nop))
      expect(cpu.pc).to(eq(0))
      expect(cpu.next_pc).to(eq(0))
    end

    it "raises DecodeError for unknown opcode words" do
      # 0xffff is not a valid AVR opcode
      device.flash.set_word(0, 0xffff)
      expect do
        cpu.decode
      end.to(raise_error(AVR::CPU::DecodeError, /Unable to decode 0xffff at offset 0x0000/))
    end
  end

  describe "#step and #trace" do
    it "executes instruction and invokes trace callback" do
      # ldi r16, 42 -> 0xe20a
      device.flash.set_word(0, 0xe20a)
      cpu.pc.value = 0
      cpu.next_pc.value = 0

      traced = []
      cpu.trace do |instruction|
        traced << instruction.to_s
      end

      cpu.step

      expect(cpu.r16.value).to(eq(42))
      expect(cpu.pc).to(eq(1))
      expect(traced).to(eq(["ldi r16, 0x2a"]))
    end

    it "catches, prints status, and re-raises execution errors" do
      device.flash.set_word(0, 0x0000) # nop
      cpu.pc.value = 0
      cpu.next_pc.value = 0

      inst = cpu.instruction(:nop)
      allow(inst).to(receive(:execute)).and_raise(RuntimeError, "Execution exploded")
      allow(cpu).to(receive(:decode)).and_return(inst)

      expect do
        expect { cpu.step }.to(output(/Caught exception while executing/m).to_stdout)
      end.to(raise_error(RuntimeError, "Execution exploded"))
    end
  end

  describe "#interrupt" do
    it "clears I flag, pushes return address, and jumps to vector by symbol" do
      cpu.pc.value = 0x0100
      cpu.next_pc.value = 0x0100
      cpu.sreg.I = true

      cpu.interrupt(:INT0) # INT0 vector is 0x0002 on ATmega328p

      expect(cpu.sreg.I).to(be(false))
      expect(cpu.pc).to(eq(0x0002))
    end

    it "clears I flag, pushes return address, and jumps to vector by number" do
      cpu.pc.value = 0x0100
      cpu.next_pc.value = 0x0100
      cpu.sreg.I = true

      cpu.interrupt(1) # vector 1 is INT0 -> address 0x0002

      expect(cpu.sreg.I).to(be(false))
      expect(cpu.pc).to(eq(0x0002))
    end

    it "raises error on unknown interrupt vector name" do
      expect do
        cpu.interrupt(:UNKNOWN_INT)
      end.to(raise_error(TypeError))
    end
  end

  describe "#notify_at_tick" do
    it "invokes callback when clock reaches target tick" do
      device.flash.set_word(0, 0x0000)
      device.flash.set_word(1, 0x0000)
      cpu.pc.value = 0
      cpu.next_pc.value = 0

      notified = false
      cpu.notify_at_tick(1) do
        notified = true
      end

      cpu.clock.tick # tick 0 (ticks becomes 1)
      expect(notified).to(be(false))

      cpu.clock.tick # tick 1 (watches[1] triggers, ticks becomes 2)
      expect(notified).to(be(true))
    end
  end

  describe "#print_status" do
    it "outputs CPU status without error" do
      expect { cpu.print_status }.to(output(/Status:.*PC = 0x0000 words/m).to_stdout)
    end
  end
end
