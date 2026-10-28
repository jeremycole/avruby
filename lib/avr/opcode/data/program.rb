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
      args.fetch(0).value = mwr.handle_modification(1) do |r|
        cpu.device.flash[r.value].value
      end
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
      rampz = cpu.io_registers.registers["RAMPZ"]&.value || 0 # Devices with < 64 KiB Flash don't have RAMPZ
      mwr = T.cast(args.fetch(1), RegisterWithModification)
      args.fetch(0).value = mwr.handle_modification(1) do |r|
        cpu.device.flash[(rampz << 16) | r.value].value
      end
    end

    decode("1001 0101 1110 1000", :spm) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:spm)
    end

    decode("1001 0101 1111 1000", :spm) do |cpu, _opcode_definition, _operands|
      cpu.instruction(:spm, RegisterWithModification.new(cpu.Z, :post_increment))
    end

    opcode(:spm, [Arg.modifying_word_register.optional]) do |cpu, _memory, args|
      args = [RegisterWithModification.new(cpu.Z)] if args.empty?
      rampz = cpu.io_registers.registers["RAMPZ"]&.value || 0  # Devices with < 64 KiB Flash don't have RAMPZ
      mwr = T.cast(args.fetch(0), RegisterWithModification)

      mwr.handle_modification(2) do |r|
        address = (rampz << 16) | r.value
        cpu.device.flash[address].value = cpu.r0.value
        cpu.device.flash[address + 1].value = cpu.r1.value
      end
    end
  end
end
