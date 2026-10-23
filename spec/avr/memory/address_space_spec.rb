# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Memory::AddressSpace) do
  subject(:space) { described_class.new("DataAddressSpace", 0x100) }

  let(:mem_a) { AVR::Memory::MemoryByteBacked.new("MemA", 0x20, 0x11) }
  let(:mem_b) { AVR::Memory::MemoryByteBacked.new("MemB", 0x40, 0x22) }

  it "initializes with name and size" do
    expect(space.name).to(eq("DataAddressSpace"))
    expect(space.size).to(eq(0x100))
  end

  it "attaches memory regions and accesses bytes via translated offset" do
    space.attach(mem_a, 0x00)
    space.attach(mem_b, 0x20)

    expect(space[0x00].value).to(eq(0x11))
    expect(space[0x1f].value).to(eq(0x11))
    expect(space[0x20].value).to(eq(0x22))
    expect(space[0x5f].value).to(eq(0x22))

    space[0x20].value = 0x99
    expect(mem_b[0].value).to(eq(0x99))
  end

  it "raises OverlappingMemoryError when attaching memory that overlaps" do
    space.attach(mem_a, 0x10)

    expect do
      space.attach(mem_b, 0x20)
    end.to(raise_error(AVR::Memory::AddressSpace::OverlappingMemoryError, /overlaps with/i))
  end

  it "raises UnattachedMemoryError when accessing an unattached address" do
    space.attach(mem_a, 0x00)

    expect do
      space[0x80]
    end.to(raise_error(AVR::Memory::AddressSpace::UnattachedMemoryError, /is not attached/i))
  end
end
