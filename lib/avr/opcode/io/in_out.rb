# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    parse_operands("____ _AAd dddd AAAA") do |cpu, operands|
      {
        Rd: cpu.registers.fetch(operands.fetch(:d).value),
        A:  operands.fetch(:A),
      }
    end

    decode("1011 0AAd dddd AAAA", :in) do |cpu, _opcode_definition, operands|
      cpu.instruction(:in, operands.fetch(:Rd), operands.fetch(:A))
    end

    opcode(:in, [Arg.register, Arg.io_address]) do |cpu, _memory, args|
      reg = cpu.device.io_registers.fetch(args.fetch(1).value)
      args.fetch(0).value = cpu.send(T.must(reg)).value
    end

    parse_operands("____ _AAr rrrr AAAA") do |cpu, operands|
      {
        Rr: cpu.registers.fetch(operands.fetch(:r).value),
        A:  operands.fetch(:A),
      }
    end

    decode("1011 1AAr rrrr AAAA", :out) do |cpu, _opcode_definition, operands|
      cpu.instruction(:out, operands.fetch(:A), operands.fetch(:Rr))
    end

    opcode(:out, [Arg.io_address, Arg.register]) do |cpu, _memory, args|
      reg = cpu.device.io_registers.fetch(args.fetch(0).value)
      cpu.send(T.must(reg)).value = args.fetch(1).value
    end
  end
end
