require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :sbi] do
  include_examples "opcode", :sbi

  let(:portb) { cpu.PORTB.memory_byte } 
  let(:portb_io_address) { cpu.PORTB.memory_byte.address - device.io_register_start }

  it "sets the bit in the IO register" do
    cpu.instruction(:sbi, portb_io_address, 1).execute
    expect(portb.value).to eq 2
  end

  it "doesn't change other bits in the IO register" do
    portb.value = 2
    cpu.instruction(:sbi, portb_io_address, 3).execute
    expect(portb.value).to eq 10
  end

  it "doesn't do anything if the bit is already set" do
    portb.value = 10
    cpu.instruction(:sbi, portb_io_address, 3).execute
    expect(portb.value).to eq 10
  end
end