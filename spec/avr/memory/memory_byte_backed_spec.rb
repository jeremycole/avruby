# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Memory::MemoryByteBacked) do
  subject(:mem) { described_class.new("TestMem", 8, 0x55) }

  it "initializes memory with given size and default value" do
    expect(mem.size).to(eq(8))
    expect(mem.name).to(eq("TestMem"))
    expect(mem[0].value).to(eq(0x55))
    expect(mem[7].value).to(eq(0x55))
  end

  it "accesses bytes with []" do
    expect(mem[3]).to(be_a(AVR::MemoryByte))
    expect(mem[3].address).to(eq(3))
  end

  it "resets all bytes to 0 on reset" do
    mem.reset
    8.times do |i|
      expect(mem[i].value).to(eq(0))
    end
  end

  describe "watches" do
    it "triggers watch without filter on any byte change" do
      events = []
      mem.watch do |byte, old_val, new_val|
        events << [byte.address, old_val, new_val]
      end

      mem[2].value = 0x11
      mem[5].value = 0x22

      expect(events).to(eq([
        [2, 0x55, 0x11],
        [5, 0x55, 0x22],
      ]))
    end

    it "triggers watch with single integer address filter" do
      events = []
      mem.watch(3) do |byte, old_val, new_val|
        events << [byte.address, old_val, new_val]
      end

      mem[2].value = 0x11
      mem[3].value = 0x33
      mem[4].value = 0x44

      expect(events).to(eq([
        [3, 0x55, 0x33],
      ]))
    end

    it "triggers watch with array filter" do
      events = []
      mem.watch([1, 4]) do |byte, old_val, new_val|
        events << [byte.address, old_val, new_val]
      end

      mem[0].value = 0xaa
      mem[1].value = 0xbb
      mem[2].value = 0xcc
      mem[4].value = 0xdd

      expect(events).to(eq([
        [1, 0x55, 0xbb],
        [4, 0x55, 0xdd],
      ]))
    end

    it "supports unshift_watch to execute before other watches" do
      order = []
      watch1 = AVR::Memory::MemoryByteBacked::Watch.new { order << :first }
      watch2 = AVR::Memory::MemoryByteBacked::Watch.new { order << :second }

      mem.push_watch(watch2)
      mem.unshift_watch(watch1)

      mem[0].value = 0x99
      expect(order).to(eq([:first, :second]))
    end
  end
end
