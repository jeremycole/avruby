module AVR
  class Opcode
    decode("1001 1000 AAAA Abbb", :cbi) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :cbi, operands[:A], operands[:b])
    end

    opcode(:cbi, [:lower_io_address, :bit_number]) do |cpu, memory, offset, args|
      cpu.sram.memory[cpu.device.io_register_start + args[0]].value &= ~(1 << args[1])
    end

    decode("1001 1010 AAAA Abbb", :sbi) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :sbi, operands[:A], operands[:b])
    end

    opcode(:sbi, [:lower_io_address, :bit_number]) do |cpu, memory, offset, args|
      cpu.sram.memory[cpu.device.io_register_start + args[0]].value |= (1 << args[1])
    end
  end
end