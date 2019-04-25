module AVR
  class EEPROM < AVR::Memory
    ERASED_VALUE = 0xff

    attr_reader :cpu

    def initialize(size)
      super("EEPROM", size, ERASED_VALUE)
    end

    def attach(cpu)
      @cpu = cpu
      @watched_memory_bytes = {
        cpu.EEARL.memory_byte => :EEARL,
        cpu.EEARH.memory_byte => :EEARH,
        cpu.EECR.memory_byte => :EECR,
        cpu.EEDR.memory_byte => :EEDR,
      }

      @cpu.sram.watch(@watched_memory_bytes.keys.map { |m| m.address }) do |memory_byte, old_value, new_value|
        case @watched_memory_bytes[memory_byte]
        when :EECR
          handle_eecr(old_value, new_value)
        end
      end
    end

    def handle_eecr(old_value, new_value)
      old_eecr = cpu.EECR.hash_for_value(old_value)
      new_eecr = cpu.EECR.hash_for_value(new_value)

      if !old_eecr[:EEMPE] && new_eecr[:EEMPE]
        cpu.notify_at_tick(cpu.clock.ticks+4) do
          cpu.EECR.EEMPE = false
        end
      end

      if !old_eecr[:EEPE] && new_eecr[:EEPE] && new_eecr[:EEMPE]
        if (!new_eecr[:EEPM0] && !new_eecr[:EEPM1]) || new_eecr[:EEPM1]
          memory[(cpu.EEARH.value << 8) | cpu.EEARL.value].value = cpu.EEDR.value
        elsif new_eecr[:EEPM0]
          memory[(cpu.EEARH.value << 8) | cpu.EEARL.value].value = ERASED_VALUE
        end
        cpu.EECR.set_by_hash({EEMPE: false, EEPE: false})
      end

      if !old_eecr[:EERE] && new_eecr[:EERE]
        cpu.EEDR.value = memory[(cpu.EEARH.value << 8) | cpu.EEARL.value].value
        cpu.EECR.EERE = false
      end

      cpu.interrupt(:EE_READY) if cpu.sreg.I && new_eecr[:EERIE]
    end
  end
end
