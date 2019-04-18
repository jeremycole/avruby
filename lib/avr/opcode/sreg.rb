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

    parse_operands("____ ___d dddd _bbb") do |cpu, operands|
      {
        Rd: cpu.registers[operands[:d]],
        b: operands[:b],
      }
    end

    decode("1111 100d dddd 0bbb", :bld) do |cpu, opcode_definition, operands|
      cpu.instruction(:bld, operands[:Rd], operands[:b])
    end

    opcode(:bld, [:register, :bit_number]) do |cpu, memory, args|
      t_bit   = 1 << args[1]
      t_value = cpu.sreg.T ? t_bit : 0
      t_mask  = ~t_bit & 0xff
      args[0].value = (args[0].value & t_mask) | t_value
    end

    decode("1111 101d dddd 0bbb", :bst) do |cpu, opcode_definition, operands|
      cpu.instruction(:bst, operands[:Rd], operands[:b])
    end

    opcode(:bst, [:register, :bit_number], %i[T]) do |cpu, memory, args|
      cpu.sreg.T = args[0].value & (1 << args[1]) != 0
    end
  end
end
