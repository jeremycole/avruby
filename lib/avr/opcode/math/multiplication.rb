# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode("1001 11rd dddd rrrr", :mul) do |cpu, _opcode_definition, operands|
      cpu.instruction(:mul, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:mul, [Arg.register, Arg.register], [:Z, :C]) do |cpu, _memory, args|
      result = (args.fetch(0).value * args.fetch(1).value)
      cpu.sreg.from_h({ Z: result.zero?, C: (result & 0x8000) != 0 })
      cpu.r1r0.value = result
    end

    decode("0000 0010 dddd rrrr", :muls) do |cpu, _opcode_definition, operands|
      cpu.instruction(:muls, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:muls, [Arg.register, Arg.register], [:Z, :C]) do |_cpu, _memory, _args|
      raise OpcodeNotImplementedError, "muls"
    end

    decode("0000 0011 0ddd 0rrr", :mulsu) do |cpu, _opcode_definition, operands|
      cpu.instruction(:mulsu, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:mulsu, [Arg.register, Arg.register], [:Z, :C]) do |_cpu, _memory, _args|
      raise OpcodeNotImplementedError, "mulsu"
    end

    decode("0000 0011 0ddd 1rrr", :fmul) do |cpu, _opcode_definition, operands|
      cpu.instruction(:fmul, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:fmul, [Arg.register, Arg.register], [:Z, :C]) do |_cpu, _memory, _args|
      raise OpcodeNotImplementedError, "fmul"
    end

    decode("0000 0011 1ddd 0rrr", :fmuls) do |cpu, _opcode_definition, operands|
      cpu.instruction(:fmuls, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:fmuls, [Arg.register, Arg.register], [:Z, :C]) do |_cpu, _memory, _args|
      raise OpcodeNotImplementedError, "fmuls"
    end

    decode("0000 0011 1ddd 1rrr", :fmulsu) do |cpu, _opcode_definition, operands|
      cpu.instruction(:fmulsu, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:fmulsu, [Arg.register, Arg.register], [:Z, :C]) do |_cpu, _memory, _args|
      raise OpcodeNotImplementedError, "fmulsu"
    end
  end
end
