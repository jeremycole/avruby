# typed: false
require "shared_examples_for_opcode"

RSpec.describe([AVR::Opcode, :break]) do
  include_examples "opcode", :break

  it "does nothing" do
    cpu.instruction(:break).execute
  end
end
