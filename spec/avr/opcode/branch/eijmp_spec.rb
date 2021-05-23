# typed: false
require "shared_examples_for_opcode"

RSpec.describe([AVR::Opcode, :eijmp]) do
  include_examples "opcode", :eijmp

  it "raises OpcodeNotImplementedError" do
    expect { cpu.instruction(:eijmp).execute }.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
  end
end
