module AVR
  class Opcode
    opcode(:brbs, [:sreg_bit, :offset]) do |cpu, memory, offset, args|
      cpu.pc += args[1] if cpu.sreg.send(args[0])
    end

    opcode(:brbc, [:sreg_bit, :offset]) do |cpu, memory, offset, args|
      cpu.pc += args[1] unless cpu.sreg.send(args[0])
    end
  end
end