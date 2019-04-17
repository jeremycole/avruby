module AVR
  class Opcode
    parse_operands("____ __kk kkkk ksss") do |cpu, operands|
      {
        k: twos_complement(operands[:k], 7),
        s: AVR::SREG::STATUS_BITS[operands[:s]],
      }
    end

    decode("1111 00kk kkkk ksss", :brbs) do |cpu, opcode_definition, operands|
      cpu.instruction(:brbs, operands[:s], operands[:k])
    end

    opcode(:brbs, [:sreg_flag, :near_relative_pc]) do |cpu, memory, args|
      cpu.next_pc = cpu.pc + args[1] + 1 if cpu.sreg.send(args[0])
    end

    decode("1111 01kk kkkk ksss", :brbc) do |cpu, opcode_definition, operands|
      cpu.instruction(:brbc, operands[:s], operands[:k])
    end

    opcode(:brbc, [:sreg_flag, :near_relative_pc]) do |cpu, memory, args|
      cpu.next_pc = cpu.pc + args[1] + 1 unless cpu.sreg.send(args[0])
    end

    decode("0001 00rd dddd rrrr", :cpse) do |cpu, opcode_definition, operands|
      cpu.instruction(:cpse, operands[:Rd], operands[:Rr])
    end

    opcode(:cpse, [:register, :register]) do |cpu, memory, args|
      cpu.decode if args[0].value == args[1].value
    end

    decode("1111 110r rrrr 0bbb", :sbrc) do |cpu, opcode_definition, operands|
      cpu.instruction(:sbrc, operands[:Rr], operands[:b])
    end

    opcode(:sbrc, [:register, :bit_number]) do |cpu, memory, args|
      cpu.decode if args[0].value & (1 << args[1]) == 0
    end

    decode("1111 111r rrrr 0bbb", :sbrs) do |cpu, opcode_definition, operands|
      cpu.instruction(:sbrs, operands[:Rr], operands[:b])
    end

    opcode(:sbrs, [:register, :bit_number]) do |cpu, memory, args|
      cpu.decode if args[0].value & (1 << args[1]) != 0
    end
  end
end