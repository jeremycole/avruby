module AVR
  class Opcode
    decode("0000 0000 0000 0000", :nop) do |cpu, offset, opcode_definition, operands|
      cpu.instruction(offset, :nop)
    end

    opcode(:nop) do |cpu, memory, offset, args|
      # Do nothing.
    end
  end
end