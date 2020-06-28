# typed: strict
# frozen_string_literal: true

module AVR
  class Opcode
    decode('1001 1000 AAAA Abbb', :cbi) do |cpu, _opcode_definition, operands|
      cpu.instruction(:cbi, operands.fetch(:A), operands.fetch(:b))
    end

    opcode(:cbi, %i[lower_io_address bit_number]) do |cpu, _memory, args|
      cpu.sram.memory.fetch(cpu.device.io_register_start + args.fetch(0).value).value &= ~(1 << args.fetch(1).value)
    end

    decode('1001 1010 AAAA Abbb', :sbi) do |cpu, _opcode_definition, operands|
      cpu.instruction(:sbi, operands.fetch(:A), operands.fetch(:b))
    end

    opcode(:sbi, %i[lower_io_address bit_number]) do |cpu, _memory, args|
      cpu.sram.memory.fetch(cpu.device.io_register_start + args.fetch(0).value).value |= (1 << args.fetch(1).value)
    end
  end
end
