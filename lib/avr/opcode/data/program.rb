module AVR
  class Opcode
    decode("1001 0101 1100 1000", :lpm) do |cpu, opcode_definition, operands|
      cpu.instruction(:lpm, cpu.r0, cpu.Z)
    end

    decode("1001 000d dddd 0100", :lpm) do |cpu, opcode_definition, operands|
      cpu.instruction(:lpm, operands[:Rd], cpu.Z)
    end

    decode("1001 000d dddd 0101", :lpm) do |cpu, opcode_definition, operands|
      cpu.instruction(:lpm, operands[:Rd], [cpu.Z, :post_increment])
    end

    opcode(:lpm, [:register, :modifying_word_register]) do |cpu, memory, args|
      args[1] = [args[1]] unless args[1].is_a?(Array)
      args[1][0].value -= 1 if args[1][1] == :pre_decrement
      args[0].value = cpu.device.flash.memory[args[1][0].value].value
      args[1][0].value += 1 if args[1][1] == :post_increment
    end
  end
end