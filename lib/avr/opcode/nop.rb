module AVR
  class Opcode
    opcode(:nop) do |cpu, memory, offset, args|
      # Do nothing.
    end
  end
end