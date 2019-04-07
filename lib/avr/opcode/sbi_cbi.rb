module AVR
  class Opcode
    opcode(:cbi, [:io_address, :bit_number]) do |cpu, memory, offset, args|
      cpu.sram.memory[args[0]].value &= ~(1 << args[1])
    end

    opcode(:sbi, [:io_address, :bit_number]) do |cpu, memory, offset, args|
      cpu.sram.memory[args[0]].value |= (1 << args[1])
    end
  end
end