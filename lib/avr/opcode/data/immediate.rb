# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode('1110 KKKK dddd KKKK', :ldi) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ldi, operands.fetch(:Rd), operands.fetch(:K))
    end

    opcode(:ldi, %i[register byte]) do |_cpu, _memory, args|
      args.fetch(0).value = args.fetch(1).value
    end
  end
end
