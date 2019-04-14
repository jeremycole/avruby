RSpec.shared_examples "opcode" do |opcode, *args|
  before(:all) do |example|
    @device = AVR::Device::Atmel_ATmega328p.new
    @cpu = @device.cpu
    @sreg_mask = @cpu.sreg.mask_for_flags(AVR::Opcode::OPCODES[opcode].sreg_flags)
  end

  before(:each) do |example|
    @cpu.reset_to_clean_state
  end

  after(:each) do |example|
    expect(@cpu.sreg.value & ~@sreg_mask).to eq 0
  end

  it "is implemented" do
    expect(AVR::Opcode::OPCODES).to include(opcode)
  end
end