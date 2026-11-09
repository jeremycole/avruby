# typed: strict
# frozen_string_literal: true

module AVR
  class Memory
    class EEPROM < MemoryByteBacked
      extend T::Sig

      ERASED_VALUE = 0xff

      sig { returns(CPU) }
      attr_reader :cpu

      sig { params(size: Integer, cpu: CPU).void }
      def initialize(size, cpu)
        super("EEPROM", size, ERASED_VALUE)
        @cpu = cpu
        @watched_memory_bytes = T.let({}, T::Hash[MemoryByte, Symbol])

        attach(cpu)
      end

      sig { returns(MemoryByteRegister) }
      def eearl
        T.cast(cpu.io_registers.fetch(:EEARL), MemoryByteRegister)
      end

      sig { returns(MemoryByteRegister) }
      def eearh
        T.cast(cpu.io_registers.fetch(:EEARH), MemoryByteRegister)
      end

      sig { returns(MemoryByteRegisterWithNamedBits) }
      def eecr
        T.cast(cpu.io_registers.fetch(:EECR), MemoryByteRegisterWithNamedBits)
      end

      sig { returns(MemoryByteRegister) }
      def eedr
        T.cast(cpu.io_registers.fetch(:EEDR), MemoryByteRegister)
      end

      sig { params(_cpu: CPU).void }
      def attach(_cpu)
        @watched_memory_bytes[eearl.memory_byte] = :EEARL
        @watched_memory_bytes[eearh.memory_byte] = :EEARH
        @watched_memory_bytes[eecr.memory_byte] = :EECR
        @watched_memory_bytes[eedr.memory_byte] = :EEDR

        @cpu.io_register_memory.watch(@watched_memory_bytes.keys.map(&:address)) do |memory_byte, old_value, new_value|
          case @watched_memory_bytes[memory_byte]
          when :EECR
            handle_eecr(old_value, new_value)
          end
        end
      end

      sig { params(old_value: Integer, new_value: Integer).void }
      def handle_eecr(old_value, new_value)
        old_eecr = eecr.hash_for_value(old_value)
        new_eecr = eecr.hash_for_value(new_value)

        if !old_eecr[:EEMPE] && new_eecr[:EEMPE]
          cpu.notify_at_tick(cpu.clock.ticks + 4) do
            eecr.set(:EEMPE, 0)
          end
        end

        if !old_eecr[:EEPE] && new_eecr[:EEPE] && new_eecr[:EEMPE]
          if (!new_eecr[:EEPM0] && !new_eecr[:EEPM1]) || new_eecr[:EEPM1]
            T.must(memory[(eearh.value << 8) | eearl.value]).value = eedr.value
          elsif new_eecr[:EEPM0]
            T.must(memory[(eearh.value << 8) | eearl.value]).value = ERASED_VALUE
          end
          eecr.set(:EEMPE, 0)
          eecr.set(:EEPE, 0)
        end

        if !old_eecr[:EERE] && new_eecr[:EERE]
          eedr.value = T.must(memory[(eearh.value << 8) | eearl.value]).value
          eecr.set(:EERE, 0)
        end

        cpu.interrupt(:EE_READY) if cpu.sreg.I? && new_eecr[:EERIE]
      end
    end
  end
end
