module AVR
  class Opcode
    decode("1001 0101 1000 1000", :sleep) do |cpu, opcode_definition, operands|
      cpu.instruction(:sleep)
    end

    opcode(:sleep) do |cpu, memory, args|
      # Do nothing.
    end
  end
end