module AVR
  class Opcode
    decode("1111 00kk kkkk ksss", :brbs) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :brbs, operands[:s], operands[:k])
    end

    opcode(:brbs, [:sreg_flag, :near_relative_pc]) do |cpu, memory, offset, args|
      cpu.next_pc = cpu.pc + args[1] + 1 if cpu.sreg.send(args[0])
    end

    decode("1111 01kk kkkk ksss", :brbc) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :brbc, operands[:s], operands[:k])
    end

    opcode(:brbc, [:sreg_flag, :near_relative_pc]) do |cpu, memory, offset, args|
      cpu.next_pc = cpu.pc + args[1] + 1 unless cpu.sreg.send(args[0])
    end
  end
end