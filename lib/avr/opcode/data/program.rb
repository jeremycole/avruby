# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode("1001 0101 1100 1000", :lpm) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:lpm)
    end

    decode("1001 000d dddd 0100", :lpm) do |cpu, _opcode_definition, operands|
      cpu.instruction(:lpm, operands.fetch(:Rd), RegisterWithModification.new(cpu.Z))
    end

    decode("1001 000d dddd 0101", :lpm) do |cpu, _opcode_definition, operands|
      cpu.instruction(:lpm, operands.fetch(:Rd), RegisterWithModification.new(cpu.Z, :post_increment))
    end

    opcode(:lpm, [:register, :modifying_word_register]) do |cpu, _memory, args|
      args = [cpu.r0, RegisterWithModification.new(cpu.Z)] if args.size.zero?
      mwr = T.cast(args.fetch(1), RegisterWithModification)
      mwr.register.value -= 1 if mwr.modification == :pre_decrement
      args.fetch(0).value = cpu.device.flash.memory.fetch(mwr.register.value).value
      mwr.register.value += 1 if mwr.modification == :post_increment
    end

    decode("1001 0101 1101 1000", :elpm) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:elpm)
    end

    decode("1001 000d dddd 0110", :elpm) do |cpu, _opcode_definition, operands|
      cpu.instruction(:elpm, operands.fetch(:Rd), RegisterWithModification.new(cpu.Z))
    end

    decode("1001 000d dddd 0111", :elpm) do |cpu, _opcode_definition, operands|
      cpu.instruction(:elpm, operands.fetch(:Rd), RegisterWithModification.new(cpu.Z, :post_increment))
    end

    opcode(:elpm, [:register, :modifying_word_register]) do |_cpu, _memory, _args|
      raise OpcodeNotImplementedError, "elpm"
    end

    decode("1001 0101 1110 1000", :spm) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:spm)
    end

    decode("1001 0101 1111 1000", :spm) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:spm, RegisterWithModification.new(cpu.Z, :post_increment))
    end

    opcode(:spm, [:modifying_word_register]) do |_cpu, _memory, _args|
      raise OpcodeNotImplementedError, "spm"
    end
  end
end
