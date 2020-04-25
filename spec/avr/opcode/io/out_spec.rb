require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :out] do
  include_examples 'opcode', :out

  let(:portb) { cpu.PORTB.memory_byte }
  let(:portb_io_address) { cpu.PORTB.memory_byte.address - device.io_register_start }

  it 'writes the contents of the register into the IO register' do
    cpu.r0.value = 1
    cpu.instruction(:out, portb_io_address, cpu.r0).execute
    expect(portb.value).to eq 1
  end
end
