module AVR
  class Opcode
    decode("1001 000d dddd 0000", :lds) do |cpu, opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:lds, operands[:Rd], k)
    end

    parse_operands("____ _kkk dddd kkkk") do |cpu, operands|
      {
        Rd: cpu.registers[operands[:d]],
        k: bit_jumble_for_lds_sts(k),
      }
    end

    decode("1010 0kkk dddd kkkk", :lds) do |cpu, opcode_definition, operands|
      cpu.instruction(:lds, operands[:Rd], operands[:k])
    end

    opcode(:lds, [:register, :word]) do |cpu, memory, args|
      args[0].value = cpu.sram.memory[args[1]].value
    end

    parse_operands("__q_ qq_d dddd _qqq") do |cpu, operands|
      {
        Rd: cpu.registers[operands[:d]],
        q: operands[:q],
      }
    end
    
    parse_operands("____ _kkk rrrr kkkk") do |cpu, operands|
      {
        Rr: cpu.registers[operands[:r]],
        k: bit_jumble_for_lds_sts(k),
      }
    end    
    
    decode("1001 001r rrrr 0000", :sts) do |cpu, opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:sts, k, operands[:Rr])
    end

    decode("1010 0kkk rrrr kkkk", :sts) do |cpu, opcode_definition, operands|
      cpu.instruction(:sts, operands[:k], operands[:Rr])
    end

    opcode(:sts, [:word, :register]) do |cpu, memory, args|
      cpu.sram.memory[args[0]].value = args[1].value
    end

    decode("1001 001r rrrr 1100", :st) do |cpu, opcode_definition, operands|
      cpu.instruction(:st, cpu.X, operands[:Rr])
    end

    decode("1001 001r rrrr 1101", :st) do |cpu, opcode_definition, operands|
      cpu.instruction(:st, [cpu.X, :post_increment], operands[:Rr])
    end

    decode("1001 001r rrrr 1110", :st) do |cpu, opcode_definition, operands|
      cpu.instruction(:st, [cpu.X, :pre_decrement], operands[:Rr])
    end

    decode("1000 001r rrrr 1000", :st) do |cpu, opcode_definition, operands|
      cpu.instruction(:st, cpu.Y, operands[:Rr])
    end

    decode("1001 001r rrrr 1001", :st) do |cpu, opcode_definition, operands|
      cpu.instruction(:st, [cpu.Y, :post_increment], operands[:Rr])
    end

    decode("1001 001r rrrr 1010", :st) do |cpu, opcode_definition, operands|
      cpu.instruction(:st, [cpu.Y, :pre_decrement], operands[:Rr])
    end

    opcode(:st, [:modifying_word_register, :register]) do |cpu, memory, args|
      args[0] = [args[0]] unless args[0].is_a?(Array)
      args[0][0].value -= 1 if args[0][1] == :pre_decrement
      cpu.sram.memory[args[0][0].value].value = args[1].value
      args[0][0].value += 1 if args[0][1] == :post_increment
    end

    parse_operands("__q_ qq_r rrrr _qqq") do |cpu, operands|
      {
        Rr: cpu.registers[operands[:r]],
        q: operands[:q],
      }
    end

    #decode("10q0 qq1r rrrr 1qqq", :std) do |cpu, opcode_definition, operands|
    #  cpu.instruction(:std, cpu.Y, operands[:Rr], operands[:q])
    #end
  end
end