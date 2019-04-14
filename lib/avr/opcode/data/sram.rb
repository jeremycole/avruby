module AVR
  class Opcode
    opcode(:st, [:modifying_word_register, :register]) do |cpu, memory, offset, args|
      args[0] = [args[0]] unless args[0].is_a?(Array)
      args[0][0].value -= 1 if args[0][1] == :pre_decrement
      cpu.sram.memory[args[0][0].value].value = args[1].value
      args[0][0].value += 1 if args[0][1] == :post_increment
    end
  end
end