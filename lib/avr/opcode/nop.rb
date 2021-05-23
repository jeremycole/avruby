# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode("0000 0000 0000 0000", :nop) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:nop)
    end

    opcode(:nop) do |_cpu, _memory, _args|
      # Do nothing.
    end
  end
end
