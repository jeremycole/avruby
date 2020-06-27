# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode('1001 000d dddd 0000', :lds) do |cpu, _opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:lds, operands[:Rd], k)
    end

    parse_operands('____ _kkk dddd kkkk') do |cpu, operands|
      {
        Rd: cpu.registers[operands[:d]],
        k: bit_jumble_for_lds_sts(operands[:k]),
      }
    end

    decode('1010 0kkk dddd kkkk', :lds) do |cpu, _opcode_definition, operands|
      cpu.instruction(:lds, operands[:Rd], operands[:k])
    end

    opcode(:lds, %i[register word]) do |cpu, _memory, args|
      cpu.next_pc += 1
      args[0].value = cpu.sram.memory[args[1]].value
    end

    decode('1001 000d dddd 1100', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands[:Rd], cpu.X)
    end

    decode('1001 000d dddd 1101', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands[:Rd], [cpu.X, :post_increment])
    end

    decode('1001 000d dddd 1110', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands[:Rd], [cpu.X, :pre_decrement])
    end

    decode('1000 000d dddd 1000', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands[:Rd], cpu.Y)
    end

    decode('1001 000d dddd 1001', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands[:Rd], [cpu.Y, :post_increment])
    end

    decode('1001 000d dddd 1010', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands[:Rd], [cpu.Y, :pre_decrement])
    end

    decode('1000 000d dddd 0000', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands[:Rd], cpu.Z)
    end

    decode('1001 000d dddd 0001', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands[:Rd], [cpu.Z, :post_increment])
    end

    decode('1001 000d dddd 0010', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands[:Rd], [cpu.Z, :pre_decrement])
    end

    opcode(:ld, %i[register modifying_word_register]) do |cpu, _memory, args|
      args[1] = [args[1]] unless args[1].is_a?(Array)
      args[1][0].value -= 1 if args[1][1] == :pre_decrement
      args[0].value = cpu.sram.memory[args[1][0].value].value
      args[1][0].value += 1 if args[1][1] == :post_increment
    end

    parse_operands('__q_ qq_d dddd _qqq') do |cpu, operands|
      {
        Rd: cpu.registers[operands[:d]],
        q: operands[:q],
      }
    end

    decode('10q0 qq0d dddd 1qqq', :ldd) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ldd, operands[:Rd], [cpu.Y, operands[:q]])
    end

    decode('10q0 qq0d dddd 0qqq', :ldd) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ldd, operands[:Rd], [cpu.Z, operands[:q]])
    end

    opcode(:ldd, %i[register displaced_word_register]) do |cpu, _memory, args|
      args[0].value = cpu.sram.memory[args[1][0].value + args[1][1]].value
    end

    decode('1001 001r rrrr 0000', :sts) do |cpu, _opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:sts, k, operands[:Rr])
    end

    parse_operands('____ _kkk rrrr kkkk') do |cpu, operands|
      {
        Rr: cpu.registers[operands[:r]],
        k: bit_jumble_for_lds_sts(operands[:k]),
      }
    end

    decode('1010 0kkk rrrr kkkk', :sts) do |cpu, _opcode_definition, operands|
      cpu.instruction(:sts, operands[:k], operands[:Rr])
    end

    opcode(:sts, %i[word register]) do |cpu, _memory, args|
      cpu.next_pc += 1
      cpu.sram.memory[args[0]].value = args[1].value
    end

    decode('1001 001r rrrr 1100', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, cpu.X, operands[:Rr])
    end

    decode('1001 001r rrrr 1101', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, [cpu.X, :post_increment], operands[:Rr])
    end

    decode('1001 001r rrrr 1110', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, [cpu.X, :pre_decrement], operands[:Rr])
    end

    decode('1000 001r rrrr 1000', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, cpu.Y, operands[:Rr])
    end

    decode('1001 001r rrrr 1001', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, [cpu.Y, :post_increment], operands[:Rr])
    end

    decode('1001 001r rrrr 1010', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, [cpu.Y, :pre_decrement], operands[:Rr])
    end

    decode('1000 001r rrrr 0000', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, cpu.Z, operands[:Rr])
    end

    decode('1001 001r rrrr 0001', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, [cpu.Z, :post_increment], operands[:Rr])
    end

    decode('1001 001r rrrr 0010', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, [cpu.Z, :pre_decrement], operands[:Rr])
    end

    opcode(:st, %i[modifying_word_register register]) do |cpu, _memory, args|
      args[0] = [args[0]] unless args[0].is_a?(Array)
      args[0][0].value -= 1 if args[0][1] == :pre_decrement
      cpu.sram.memory[args[0][0].value].value = args[1].value
      args[0][0].value += 1 if args[0][1] == :post_increment
    end

    parse_operands('__q_ qq_r rrrr _qqq') do |cpu, operands|
      {
        Rr: cpu.registers[operands[:r]],
        q: operands[:q],
      }
    end

    decode('10q0 qq1r rrrr 1qqq', :std) do |cpu, _opcode_definition, operands|
      cpu.instruction(:std, [cpu.Y, operands[:q]], operands[:Rr])
    end

    decode('10q0 qq1r rrrr 0qqq', :std) do |cpu, _opcode_definition, operands|
      cpu.instruction(:std, [cpu.Z, operands[:q]], operands[:Rr])
    end

    opcode(:std, %i[displaced_word_register register]) do |cpu, _memory, args|
      cpu.sram.memory[args[0][0].value + args[0][1]].value = args[1].value
    end

    sig { params(memory_byte: MemoryByte, register: Register, mnemonic: Symbol).void }
    def self.exchange_memory_byte_with_register(memory_byte, register, mnemonic)
      old_value = memory_byte.value
      case mnemonic
      when :xch
        memory_byte.value = register.value
      when :las
        memory_byte.value = register.value | old_value
      when :lac
        memory_byte.value = (~register.value & old_value) & 0xff
      when :lat
        memory_byte.value = register.value ^ old_value
      end
      register.value = old_value
    end

    decode('1001 001r rrrr 0100', :xch) do |cpu, _opcode_definition, operands|
      cpu.instruction(:xch, operands[:Rr])
    end

    opcode(:xch, %i[register]) do |cpu, _memory, args|
      exchange_memory_byte_with_register(cpu.sram.memory[cpu.Z.value], args[0], :xch)
    end

    decode('1001 001r rrrr 0101', :las) do |cpu, _opcode_definition, operands|
      cpu.instruction(:las, operands[:Rr])
    end

    opcode(:las, %i[register]) do |cpu, _memory, args|
      exchange_memory_byte_with_register(cpu.sram.memory[cpu.Z.value], args[0], :las)
    end

    decode('1001 001r rrrr 0110', :lac) do |cpu, _opcode_definition, operands|
      cpu.instruction(:lac, operands[:Rr])
    end

    opcode(:lac, %i[register]) do |cpu, _memory, args|
      exchange_memory_byte_with_register(cpu.sram.memory[cpu.Z.value], args[0], :lac)
    end

    decode('1001 001r rrrr 0111', :lat) do |cpu, _opcode_definition, operands|
      cpu.instruction(:lat, operands[:Rr])
    end

    opcode(:lat, %i[register]) do |cpu, _memory, args|
      exchange_memory_byte_with_register(cpu.sram.memory[cpu.Z.value], args[0], :lat)
    end
  end
end
