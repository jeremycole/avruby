# typed: false
# frozen_string_literal: true

module AVR
  class EEPROM < Memory
    extend T::Sig

    ERASED_VALUE = 0xff

    sig { returns(CPU) }
    attr_reader :cpu

    sig { params(size: Integer, cpu: CPU).void }
    def initialize(size, cpu)
      super("EEPROM", size, ERASED_VALUE)
      attach(cpu)
    end

    sig { params(cpu: CPU).void }
    def attach(cpu)
      @cpu = cpu
      @watched_memory_bytes = {
        cpu.EEARL.memory_byte => :EEARL,
        cpu.EEARH.memory_byte => :EEARH,
        cpu.EECR.memory_byte => :EECR,
        cpu.EEDR.memory_byte => :EEDR,
      }

      @cpu.sram.watch(@watched_memory_bytes.keys.map(&:address)) do |memory_byte, old_value, new_value|
        case @watched_memory_bytes[memory_byte]
        when :EECR
          handle_eecr(old_value, new_value)
        end
      end
    end

    sig { params(old_value: Integer, new_value: Integer).void }
    def handle_eecr(old_value, new_value)
      old_eecr = cpu.EECR.hash_for_value(old_value)
      new_eecr = cpu.EECR.hash_for_value(new_value)

      if !old_eecr[:EEMPE] && new_eecr[:EEMPE]
        cpu.notify_at_tick(cpu.clock.ticks + 4) do
          cpu.EECR.EEMPE = false
        end
      end

      if !old_eecr[:EEPE] && new_eecr[:EEPE] && new_eecr[:EEMPE]
        if (!new_eecr[:EEPM0] && !new_eecr[:EEPM1]) || new_eecr[:EEPM1]
          T.must(memory[(cpu.EEARH.value << 8) | cpu.EEARL.value]).value = cpu.EEDR.value
        elsif new_eecr[:EEPM0]
          T.must(memory[(cpu.EEARH.value << 8) | cpu.EEARL.value]).value = ERASED_VALUE
        end
        cpu.EECR.from_h({ EEMPE: false, EEPE: false })
      end

      if !old_eecr[:EERE] && new_eecr[:EERE]
        cpu.EEDR.value = T.must(memory[(cpu.EEARH.value << 8) | cpu.EEARL.value]).value
        cpu.EECR.EERE = false
      end

      cpu.interrupt(:EE_READY) if cpu.sreg.I && new_eecr[:EERIE]
    end
  end
end
