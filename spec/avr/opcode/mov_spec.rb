require 'shared_examples_for_opcode'

RSpec.describe [AVR::Opcode, :mov] do
  include_examples "opcode", :mov

  context "decoder" do
    it "extracts mnemonic and operands correctly" do
      d = @cpu.decoder.decode(0b0010_1100_0000_0001)
      expect(d.opcode_definition.mnemonic).to eq :mov
      expect(d.operands).to eq({:d=>0, :r=>1})
    end

    it "decodes from flash" do
      @device.flash.set_word(0, 0b0010_1100_0000_0001)
      i = @device.cpu.decode
      expect(i).to be_an_instance_of AVR::Instruction
      expect(i.mnemonic).to eq :mov
      expect(i.args).to eq [@cpu.r0, @cpu.r1]
    end
  end

  context "instruction" do
    before(:all) do
      @i = @cpu.instruction(0, :mov, @cpu.r0, @cpu.r1)
    end

    it "copies the source register to the target register" do
      @cpu.r0 = 0
      @cpu.r1 = 1
      @i.execute
      expect(@cpu.r0.value).to eq 1
      expect(@cpu.r1.value).to eq 1
      @cpu.r0 = 1
      @cpu.r1 = 0
      @i.execute
      expect(@cpu.r0.value).to eq 0
      expect(@cpu.r1.value).to eq 0
    end
  end
end
