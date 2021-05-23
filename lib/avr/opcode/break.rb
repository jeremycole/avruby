# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode("1001 0101 1001 1000", :break) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:break)
    end

    opcode(:break) do |_cpu, _memory, _args|
      # Do nothing.
    end
  end
end
