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

    opcode(:lpm, [Arg.register.optional, Arg.modifying_word_register.optional]) do |cpu, _memory, args|
      args = [cpu.r0, RegisterWithModification.new(cpu.Z)] if args.empty?
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

    opcode(:elpm, [Arg.register.optional, Arg.modifying_word_register.optional]) do |cpu, _memory, args|
      args = [cpu.r0, RegisterWithModification.new(cpu.Z)] if args.empty?
      mwr = T.cast(args.fetch(1), RegisterWithModification)
      mwr.register.value -= 1 if mwr.modification == :pre_decrement
      rampz = cpu.io_registers.registers["RAMPZ"]&.value || cpu.registers.registers["RAMPZ"]&.value || 0
      address = (rampz << 16) | mwr.register.value
      args.fetch(0).value = cpu.device.flash.memory.fetch(address).value
      mwr.register.value += 1 if mwr.modification == :post_increment
    end

    decode("1001 0101 1110 1000", :spm) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:spm)
    end

    decode("1001 0101 1111 1000", :spm) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:spm, RegisterWithModification.new(cpu.Z, :post_increment))
    end

    opcode(:spm, [Arg.modifying_word_register.optional]) do |cpu, _memory, args|
      args = [RegisterWithModification.new(cpu.Z)] if args.empty?
      mwr = T.cast(args.fetch(0), RegisterWithModification)
      mwr.register.value -= 2 if mwr.modification == :pre_decrement
      rampz = cpu.io_registers.registers["RAMPZ"]&.value || cpu.registers.registers["RAMPZ"]&.value || 0
      address = (rampz << 16) | mwr.register.value
      cpu.device.flash.memory.fetch(address).value = cpu.r0.value
      cpu.device.flash.memory.fetch(address + 1).value = cpu.r1.value
      mwr.register.value += 2 if mwr.modification == :post_increment
    end
  end
end
