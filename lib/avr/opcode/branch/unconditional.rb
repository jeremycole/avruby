# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode("1001 0100 0000 1100", :jmp) do |cpu, _opcode_definition, _operands|
      k = cpu.fetch
      cpu.instruction(:jmp, Value.new(k))
    end

    decode("1001 010k kkkk 110k", :jmp) do |cpu, _opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:jmp, Value.new((operands.fetch(:k).value << 16) | k))
    end

    opcode(:jmp, [Arg.absolute_pc]) do |cpu, _memory, args|
      cpu.next_pc = args.fetch(0).value
    end

    decode("1001 0100 0000 1110", :call) do |cpu, _opcode_definition, _operands|
      k = cpu.fetch
      cpu.instruction(:call, Value.new(k))
    end

    decode("1001 010k kkkk 111k", :call) do |cpu, _opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:call, Value.new((operands.fetch(:k).value << 16) | k))
    end

    opcode(:call, [Arg.absolute_pc]) do |cpu, _memory, args|
      stack_push_word(cpu, cpu.pc + 2)
      cpu.next_pc = args.fetch(0).value
    end

    # rcall rjmp
    parse_operands("____ kkkk kkkk kkkk") do |_cpu, operands|
      { k: Value.new(from_twos_complement(operands.fetch(:k).value, 12)) }
    end

    decode("1100 kkkk kkkk kkkk", :rjmp) do |cpu, _opcode_definition, operands|
      cpu.instruction(:rjmp, operands.fetch(:k))
    end

    opcode(:rjmp, [Arg.far_relative_pc]) do |cpu, _memory, args|
      cpu.next_pc = cpu.pc + args.fetch(0).value + 1
    end

    decode("1101 kkkk kkkk kkkk", :rcall) do |cpu, _opcode_definition, operands|
      cpu.instruction(:rcall, operands.fetch(:k))
    end

    opcode(:rcall, [Arg.far_relative_pc]) do |cpu, _memory, args|
      stack_push_word(cpu, cpu.pc + 1)
      cpu.next_pc = cpu.pc + args.fetch(0).value + 1
    end

    decode("1001 0100 0000 1001", :ijmp) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:ijmp)
    end

    opcode(:ijmp) do |cpu, _memory, _args|
      cpu.next_pc = cpu.Z.value
    end

    decode("1001 0101 0000 1001", :icall) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:icall)
    end

    opcode(:icall) do |cpu, _memory, _args|
      stack_push_word(cpu, cpu.pc + 1)
      cpu.next_pc = cpu.Z.value
    end

    decode("1001 0100 0001 1001", :eijmp) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:eijmp)
    end

    opcode(:eijmp) do |_cpu, _memory, _args|
      raise OpcodeNotImplementedError, "eijmp"
    end

    decode("1001 0101 0001 1001", :eicall) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:eicall)
    end

    opcode(:eicall) do |_cpu, _memory, _args|
      raise OpcodeNotImplementedError, "eicall"
    end
  end
end
