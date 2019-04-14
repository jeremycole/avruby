module AVR
  class Opcode
    opcode(:lpm, [:register, :modifying_word_register]) do |cpu, memory, offset, args|
      args[1] = [args[1]] unless args[1].is_a?(Array)
      args[1][0].value -= 1 if args[1][1] == :pre_decrement
      args[0].value = cpu.device.flash.memory[args[1][0].value].value
      args[1][0].value += 1 if args[1][1] == :post_increment
    end
  end
end