# typed: false
require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :nop] do
  include_examples 'opcode', :nop

  it 'does nothing' do
    cpu.instruction(:nop).execute
  end
end
