# typed: false

RSpec.shared_examples("opcode") do |opcode, *_args|
  let(:device) { AVR::Device::Atmel_ATmega328p.new }
  let(:cpu) { device.cpu }
  let(:sreg_mask) { cpu.sreg.mask_for_flags(AVR::Opcode.opcodes[opcode].sreg_flags) }

  before do
    cpu.reset_to_clean_state
  end

  after do
    expect(cpu.sreg.value & ~sreg_mask).to(eq(0)) # rubocop:disable RSpec/ExpectInHook
  end

  it "is a known opcode" do
    expect(AVR::Opcode.opcodes).to(include(opcode))
  end
end
