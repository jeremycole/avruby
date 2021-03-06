# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode("0010 11rd dddd rrrr", :mov) do |cpu, _opcode_definition, operands|
      cpu.instruction(:mov, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:mov, [Arg.register, Arg.register]) do |_cpu, _memory, args|
      args.fetch(0).value = args.fetch(1).value
    end

    decode("0000 0001 DDDD RRRR", :movw) do |cpu, _opcode_definition, operands|
      cpu.instruction(:movw, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:movw, [Arg.register_pair, Arg.register_pair]) do |_cpu, _memory, args|
      args.fetch(0).value = args.fetch(1).value
    end
  end
end
