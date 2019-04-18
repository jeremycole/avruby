module AVR
  class Opcode
    decode("1001 0101 1001 1000", :break) do |cpu, opcode_definition, operands|
      cpu.instruction(:break)
    end

    opcode(:break) do |cpu, memory, args|
      # Do nothing.
    end
  end
end