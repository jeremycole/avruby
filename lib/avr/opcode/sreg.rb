module AVR
  class Opcode
    decode("1001 0100 0sss 1000", :bset) do |cpu, opcode_definition, operands|
      cpu.instruction(:bset, AVR::SREG::STATUS_BITS[operands[:s]])
    end

    opcode(:bset, [:sreg_flag], %i[I T H S V N Z C]) do |cpu, memory, args|
      cpu.sreg.set_by_hash({args[0] => true});
    end

    decode("1001 0100 1sss 1000", :bclr) do |cpu, opcode_definition, operands|
      cpu.instruction(:bclr, AVR::SREG::STATUS_BITS[operands[:s]])
    end

    opcode(:bclr, [:sreg_flag], %i[I T H S V N Z C]) do |cpu, memory, args|
      cpu.sreg.set_by_hash({args[0] => false});
    end
  end
end
