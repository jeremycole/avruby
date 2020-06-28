# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode('1001 0101 1100 1000', :lpm) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:lpm, cpu.r0, RegisterWithModification.new(cpu.Z))
    end

    decode('1001 000d dddd 0100', :lpm) do |cpu, _opcode_definition, operands|
      cpu.instruction(:lpm, operands.fetch(:Rd), RegisterWithModification.new(cpu.Z))
    end

    decode('1001 000d dddd 0101', :lpm) do |cpu, _opcode_definition, operands|
      cpu.instruction(:lpm, operands.fetch(:Rd), RegisterWithModification.new(cpu.Z, :post_increment))
    end

    opcode(:lpm, %i[register modifying_word_register]) do |cpu, _memory, args|
      mwr = T.cast(args.fetch(1), RegisterWithModification)
      mwr.register.value -= 1 if mwr.modification == :pre_decrement
      args.fetch(0).value = cpu.device.flash.memory.fetch(mwr.register.value).value
      mwr.register.value += 1 if mwr.modification == :post_increment
    end
  end
end
