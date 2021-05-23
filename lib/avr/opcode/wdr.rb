# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode("1001 0101 1010 1000", :wdr) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:wdr)
    end

    opcode(:wdr) do |_cpu, _memory, _args|
      # Do nothing for now.
    end
  end
end
