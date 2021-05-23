# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    parse_operands("____ __kk kkkk ksss") do |_cpu, operands|
      {
        k: Value.new(twos_complement(operands.fetch(:k).value, 7)),
        s: operands.fetch(:s),
      }
    end

    decode("1111 00kk kkkk ksss", :brbs) do |cpu, _opcode_definition, operands|
      cpu.instruction(:brbs, operands.fetch(:s), operands.fetch(:k))
    end

    opcode(:brbs, [:sreg_flag, :near_relative_pc]) do |cpu, _memory, args|
      cpu.next_pc = cpu.pc + args.fetch(1).value + 1 if args.fetch(0).value == 1
    end

    decode("1111 01kk kkkk ksss", :brbc) do |cpu, _opcode_definition, operands|
      cpu.instruction(:brbc, operands.fetch(:s), operands.fetch(:k))
    end

    opcode(:brbc, [:sreg_flag, :near_relative_pc]) do |cpu, _memory, args|
      cpu.next_pc = cpu.pc + args.fetch(1).value + 1 if args.fetch(0).value == 0
    end

    decode("0001 00rd dddd rrrr", :cpse) do |cpu, _opcode_definition, operands|
      cpu.instruction(:cpse, operands.fetch(:Rd), operands.fetch(:Rr))
    end

    opcode(:cpse, [:register, :register]) do |cpu, _memory, args|
      cpu.decode if args.fetch(0).value == args.fetch(1).value
    end

    decode("1111 110r rrrr 0bbb", :sbrc) do |cpu, _opcode_definition, operands|
      register_bit = RegisterWithBitNumber.new(
        T.cast(operands.fetch(:Rr), MemoryByteRegister),
        operands.fetch(:b).value
      )
      cpu.instruction(:sbrc, register_bit)
    end

    opcode(:sbrc, [:register_with_bit_number]) do |cpu, _memory, args|
      cpu.decode if args.fetch(0).value == 0
    end

    decode("1111 111r rrrr 0bbb", :sbrs) do |cpu, _opcode_definition, operands|
      register_bit = RegisterWithBitNumber.new(
        T.cast(operands.fetch(:Rr), MemoryByteRegister),
        operands.fetch(:b).value
      )
      cpu.instruction(:sbrs, register_bit)
    end

    opcode(:sbrs, [:register_with_bit_number]) do |cpu, _memory, args|
      cpu.decode if args.fetch(0).value == 1
    end

    decode("1001 1001 AAAA Abbb", :sbic) do |cpu, _opcode_definition, operands|
      cpu.instruction(:sbic, operands.fetch(:A), operands.fetch(:b))
    end

    opcode(:sbic, [:byte, :bit_number]) do |cpu, _memory, args|
      io_register = cpu.sram.memory.fetch(cpu.device.io_register_start + args.fetch(0).value)
      cpu.decode if io_register.value & (1 << args.fetch(1).value) == 0
    end

    decode("1001 1011 AAAA Abbb", :sbis) do |cpu, _opcode_definition, operands|
      cpu.instruction(:sbis, operands.fetch(:A), operands.fetch(:b))
    end

    opcode(:sbis, [:byte, :bit_number]) do |cpu, _memory, args|
      io_register = cpu.sram.memory.fetch(cpu.device.io_register_start + args.fetch(0).value)
      cpu.decode if io_register.value & (1 << args.fetch(1).value) != 0
    end
  end
end
