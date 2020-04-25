# frozen_string_literal: true

module AVR
  class Opcode
    decode('1110 KKKK dddd KKKK', :ldi) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ldi, operands[:Rd], operands[:K])
    end

    opcode(:ldi, %i[register byte]) do |_cpu, _memory, args|
      args[0].value = args[1]
    end
  end
end
