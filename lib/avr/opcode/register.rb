# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode('0010 11rd dddd rrrr', :mov) do |cpu, _opcode_definition, operands|
      cpu.instruction(:mov, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:mov, %i[register register]) do |_cpu, _memory, args|
      args.fetch(0).value = args.fetch(1).value
    end

    parse_operands('____ ____ dddd rrrr') do |cpu, operands|
      {
        Rd: RegisterPair.new(
          cpu,
          cpu.registers.fetch((operands.fetch(:d).value << 1) + 1),
          cpu.registers.fetch(operands.fetch(:d).value << 1)
        ),
        Rr: RegisterPair.new(
          cpu,
          cpu.registers.fetch((operands.fetch(:r).value << 1) + 1),
          cpu.registers.fetch(operands.fetch(:r).value << 1)
        ),
      }
    end

    decode('0000 0001 dddd rrrr', :movw) do |cpu, _opcode_definition, operands|
      cpu.instruction(:movw, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:movw, %i[register_pair register_pair]) do |_cpu, _memory, args|
      args.fetch(0).value = args.fetch(1).value
    end
  end
end
