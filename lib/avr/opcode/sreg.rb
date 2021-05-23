# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode("1001 0100 0sss 1000", :bset) do |cpu, _opcode_definition, operands|
      sreg_bit = RegisterWithNamedBit.new(
        cpu.sreg,
        SREG::STATUS_BITS.fetch(operands.fetch(:s).value)
      )
      cpu.instruction(:bset, sreg_bit)
    end

    opcode(:bset, [Arg.sreg_flag], [:I, :T, :H, :S, :V, :N, :Z, :C]) do |_cpu, _memory, args|
      args.fetch(0).value = 1
    end

    decode("1001 0100 1sss 1000", :bclr) do |cpu, _opcode_definition, operands|
      sreg_bit = RegisterWithNamedBit.new(
        cpu.sreg,
        SREG::STATUS_BITS.fetch(operands.fetch(:s).value)
      )
      cpu.instruction(:bclr, sreg_bit)
    end

    opcode(:bclr, [Arg.sreg_flag], [:I, :T, :H, :S, :V, :N, :Z, :C]) do |_cpu, _memory, args|
      args.fetch(0).value = 0
    end

    parse_operands("____ ___d dddd _bbb") do |cpu, operands|
      {
        Rd: cpu.registers.fetch(operands.fetch(:d).value),
        b: operands.fetch(:b),
      }
    end

    decode("1111 100d dddd 0bbb", :bld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:bld, operands.fetch(:Rd), operands.fetch(:b))
    end

    opcode(:bld, [Arg.register, Arg.bit_number]) do |cpu, _memory, args|
      t_bit   = 1 << args.fetch(1).value
      t_value = cpu.sreg.T ? t_bit : 0
      t_mask  = ~t_bit & 0xff
      args.fetch(0).value = (args.fetch(0).value & t_mask) | t_value
    end

    decode("1111 101d dddd 0bbb", :bst) do |cpu, _opcode_definition, operands|
      cpu.instruction(:bst, operands.fetch(:Rd), operands.fetch(:b))
    end

    opcode(:bst, [Arg.register, Arg.bit_number], [:T]) do |cpu, _memory, args|
      cpu.sreg.T = args.fetch(0).value & (1 << args.fetch(1).value) != 0
    end
  end
end
