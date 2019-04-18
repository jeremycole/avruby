module AVR
  class Opcode
    decode("1001 0101 1010 1000", :wdr) do |cpu, opcode_definition, operands|
      cpu.instruction(:wdr)
    end

    opcode(:wdr) do |cpu, memory, args|
      # Do nothing for now.
    end
  end
end