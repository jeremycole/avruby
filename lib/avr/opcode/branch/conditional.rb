module AVR
  class Opcode
    opcode(:brbs, [:sreg_flag, :near_relative_pc]) do |cpu, memory, offset, args|
      cpu.pc += args[1] if cpu.sreg.send(args[0])
    end

    opcode(:brbc, [:sreg_flag, :near_relative_pc]) do |cpu, memory, offset, args|
      cpu.pc += args[1] unless cpu.sreg.send(args[0])
    end
  end
end