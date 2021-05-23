# typed: false
require "shared_examples_for_opcode"

RSpec.describe([AVR::Opcode, :des]) do
  include_examples "opcode", :des

  it "raises OpcodeNotImplementedError" do
    expect { cpu.instruction(:des, AVR::Value.new(0)).execute }.to(raise_error(AVR::Opcode::OpcodeNotImplementedError))
  end
end
