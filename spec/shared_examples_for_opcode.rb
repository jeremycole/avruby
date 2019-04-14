RSpec.shared_examples "opcode" do |opcode, *args|
  device = AVR::Device::Atmel_ATmega328p.new
  cpu = device.cpu

  it "is implemented" do
    expect(AVR::Opcode::OPCODES).to include(opcode)
  end

  it "can be instantiated" do
    i = cpu.instruction(0, opcode, *args)
    expect(i).to be_an_instance_of AVR::Instruction
  end

  it "can be executed" do
    i = cpu.instruction(0, opcode, *args)
    expect(i.execute)
  end
end