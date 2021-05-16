# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode('1001 000d dddd 0000', :lds) do |cpu, _opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:lds, operands.fetch(:Rd), k)
    end

    parse_operands('____ _kkk dddd kkkk') do |cpu, operands|
      {
        Rd: cpu.registers.fetch(operands.fetch(:d).value + 16),
        k: bit_jumble_for_lds_sts(operands.fetch(:k).value),
      }
    end

    decode('1010 0kkk dddd kkkk', :lds) do |cpu, _opcode_definition, operands|
      cpu.instruction(:lds, operands.fetch(:Rd), operands.fetch(:k))
    end

    opcode(:lds, %i[register word]) do |cpu, _memory, args|
      cpu.next_pc += 1
      args.fetch(0).value = cpu.sram.memory.fetch(args.fetch(1).value).value
    end

    decode('1001 000d dddd 1100', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands.fetch(:Rd), RegisterWithModification.new(cpu.X))
    end

    decode('1001 000d dddd 1101', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands.fetch(:Rd), RegisterWithModification.new(cpu.X, :post_increment))
    end

    decode('1001 000d dddd 1110', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands.fetch(:Rd), RegisterWithModification.new(cpu.X, :pre_decrement))
    end

    decode('1000 000d dddd 1000', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands.fetch(:Rd), RegisterWithModification.new(cpu.Y))
    end

    decode('1001 000d dddd 1001', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands.fetch(:Rd), RegisterWithModification.new(cpu.Y, :post_increment))
    end

    decode('1001 000d dddd 1010', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands.fetch(:Rd), RegisterWithModification.new(cpu.Y, :pre_decrement))
    end

    decode('1000 000d dddd 0000', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands.fetch(:Rd), RegisterWithModification.new(cpu.Z))
    end

    decode('1001 000d dddd 0001', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands.fetch(:Rd), RegisterWithModification.new(cpu.Z, :post_increment))
    end

    decode('1001 000d dddd 0010', :ld) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ld, operands.fetch(:Rd), RegisterWithModification.new(cpu.Z, :pre_decrement))
    end

    opcode(:ld, %i[register modifying_word_register]) do |cpu, _memory, args|
      mwr = T.cast(args.fetch(1), RegisterWithModification)
      mwr.register.value -= 1 if mwr.modification == :pre_decrement
      args.fetch(0).value = cpu.sram.memory.fetch(mwr.register.value).value
      mwr.register.value += 1 if mwr.modification == :post_increment
    end

    parse_operands('__q_ qq_d dddd _qqq') do |cpu, operands|
      {
        Rd: cpu.registers.fetch(operands.fetch(:d).value),
        q: operands.fetch(:q),
      }
    end

    decode('10q0 qq0d dddd 1qqq', :ldd) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ldd, operands.fetch(:Rd), RegisterWithDisplacement.new(cpu.Y, operands.fetch(:q).value))
    end

    decode('10q0 qq0d dddd 0qqq', :ldd) do |cpu, _opcode_definition, operands|
      cpu.instruction(:ldd, operands.fetch(:Rd), RegisterWithDisplacement.new(cpu.Z, operands.fetch(:q).value))
    end

    opcode(:ldd, %i[register displaced_word_register]) do |cpu, _memory, args|
      dwr = T.cast(args.fetch(1), RegisterWithDisplacement)
      args.fetch(0).value = cpu.sram.memory.fetch(dwr.register.value + dwr.displacement).value
    end

    decode('1001 001r rrrr 0000', :sts) do |cpu, _opcode_definition, operands|
      k = cpu.fetch
      cpu.instruction(:sts, k, operands.fetch(:Rr))
    end

    parse_operands('____ _kkk rrrr kkkk') do |cpu, operands|
      {
        Rr: cpu.registers.fetch(operands.fetch(:r).value + 16),
        k: bit_jumble_for_lds_sts(operands.fetch(:k).value),
      }
    end

    # TODO: The 16-bit STS instruction has a very weird encoding that conflicts with LDD.
    #       Needs more work to support decode properly.
    # decode('1010 1kkk rrrr kkkk', :sts) do |cpu, _opcode_definition, operands|
    #   cpu.instruction(:sts, operands.fetch(:k), operands.fetch(:Rr))
    # end

    opcode(:sts, %i[word register]) do |cpu, _memory, args|
      cpu.next_pc += 1
      cpu.sram.memory.fetch(args.fetch(0).value).value = args.fetch(1).value
    end

    decode('1001 001r rrrr 1100', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, cpu.X, operands.fetch(:Rr))
    end

    decode('1001 001r rrrr 1101', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, RegisterWithModification.new(cpu.X, :post_increment), operands.fetch(:Rr))
    end

    decode('1001 001r rrrr 1110', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, RegisterWithModification.new(cpu.X, :pre_decrement), operands.fetch(:Rr))
    end

    decode('1000 001r rrrr 1000', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, RegisterWithModification.new(cpu.Y), operands.fetch(:Rr))
    end

    decode('1001 001r rrrr 1001', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, RegisterWithModification.new(cpu.Y, :post_increment), operands.fetch(:Rr))
    end

    decode('1001 001r rrrr 1010', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, RegisterWithModification.new(cpu.Y, :pre_decrement), operands.fetch(:Rr))
    end

    decode('1000 001r rrrr 0000', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, RegisterWithModification.new(cpu.Z), operands.fetch(:Rr))
    end

    decode('1001 001r rrrr 0001', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, RegisterWithModification.new(cpu.Z, :post_increment), operands.fetch(:Rr))
    end

    decode('1001 001r rrrr 0010', :st) do |cpu, _opcode_definition, operands|
      cpu.instruction(:st, RegisterWithModification.new(cpu.Z, :pre_decrement), operands.fetch(:Rr))
    end

    opcode(:st, %i[modifying_word_register register]) do |cpu, _memory, args|
      mwr = T.cast(args.fetch(0), RegisterWithModification)
      mwr.register.value -= 1 if mwr.modification == :pre_decrement
      cpu.sram.memory.fetch(mwr.register.value).value = args.fetch(1).value
      mwr.register.value += 1 if mwr.modification == :post_increment
    end

    parse_operands('__q_ qq_r rrrr _qqq') do |cpu, operands|
      {
        Rr: cpu.registers.fetch(operands.fetch(:r).value),
        q: operands.fetch(:q),
      }
    end

    decode('10q0 qq1r rrrr 1qqq', :std) do |cpu, _opcode_definition, operands|
      cpu.instruction(:std, RegisterWithDisplacement.new(cpu.Y, operands.fetch(:q).value), operands.fetch(:Rr))
    end

    decode('10q0 qq1r rrrr 0qqq', :std) do |cpu, _opcode_definition, operands|
      cpu.instruction(:std, RegisterWithDisplacement.new(cpu.Z, operands.fetch(:q).value), operands.fetch(:Rr))
    end

    opcode(:std, %i[displaced_word_register register]) do |cpu, _memory, args|
      dwr = T.cast(args.fetch(0), RegisterWithDisplacement)
      cpu.sram.memory.fetch(dwr.register.value + dwr.displacement).value = args.fetch(1).value
    end

    sig { params(memory_byte: MemoryByte, register: Value, mnemonic: Symbol).void }
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
      cpu.instruction(:xch, operands.fetch(:Rr))
    end

    opcode(:xch, %i[register]) do |cpu, _memory, args|
      exchange_memory_byte_with_register(cpu.sram.memory.fetch(cpu.Z.value), args.fetch(0), :xch)
    end

    decode('1001 001r rrrr 0101', :las) do |cpu, _opcode_definition, operands|
      cpu.instruction(:las, operands.fetch(:Rr))
    end

    opcode(:las, %i[register]) do |cpu, _memory, args|
      exchange_memory_byte_with_register(cpu.sram.memory.fetch(cpu.Z.value), args.fetch(0), :las)
    end

    decode('1001 001r rrrr 0110', :lac) do |cpu, _opcode_definition, operands|
      cpu.instruction(:lac, operands.fetch(:Rr))
    end

    opcode(:lac, %i[register]) do |cpu, _memory, args|
      exchange_memory_byte_with_register(cpu.sram.memory.fetch(cpu.Z.value), args.fetch(0), :lac)
    end

    decode('1001 001r rrrr 0111', :lat) do |cpu, _opcode_definition, operands|
      cpu.instruction(:lat, operands.fetch(:Rr))
    end

    opcode(:lat, %i[register]) do |cpu, _memory, args|
      exchange_memory_byte_with_register(cpu.sram.memory.fetch(cpu.Z.value), T.cast(args.fetch(0), Register), :lat)
    end
  end
end
