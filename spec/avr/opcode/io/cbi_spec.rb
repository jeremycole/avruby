require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :cbi] do
  include_examples 'opcode', :cbi

  let(:portb) { cpu.PORTB.memory_byte }
  let(:portb_io_address) { cpu.PORTB.memory_byte.address - device.io_register_start }

  it 'clears the bit in the IO register' do
    portb.value = 2
    cpu.instruction(:cbi, portb_io_address, 1).execute
    expect(portb.value).to eq 0
  end

  it 'does not change other bits in the IO register' do
    portb.value = 10
    cpu.instruction(:cbi, portb_io_address, 3).execute
    expect(portb.value).to eq 2
  end

  it 'does not do anything if the bit is already cleared' do
    portb.value = 2
    cpu.instruction(:cbi, portb_io_address, 3).execute
    expect(portb.value).to eq 2
  end
end
