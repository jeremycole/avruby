module AVR
  class Opcode
    decode("0000 0000 0000 0000", :nop) do |cpu, opcode_definition, operands|
      cpu.instruction(:nop)
    end

    opcode(:nop) do |cpu, memory, args|
      # Do nothing.
    end
  end
end