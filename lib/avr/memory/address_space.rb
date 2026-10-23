# typed: strict
# frozen_string_literal: true

module AVR
  class Memory
    class AddressSpace < Memory
      class AttachedMemory
        extend T::Sig

        sig { returns(Memory) }
        attr_reader :memory

        sig { returns(T::Range[Integer]) }
        attr_reader :address_range

        sig { params(memory: Memory, address_range: T::Range[Integer]).void }
        def initialize(memory, address_range)
          @memory = memory
          @address_range = address_range
        end
      end

      extend T::Sig

      class OverlappingMemoryError < StandardError; end
      class UnattachedMemoryError < StandardError; end

      sig { returns(T::Array[AttachedMemory]) }
      attr_reader :attached_memories

      sig { params(name: String, size: Integer).void }
      def initialize(name, size)
        super

        @attached_memories = T.let([], T::Array[AttachedMemory])
      end

      sig { params(memory: Memory, start_address: Integer).returns(AddressSpace) }
      def attach(memory, start_address)
        new_address_range = start_address...(start_address + memory.size)

        attached_memories.each do |attached_memory|
          next unless attached_memory.address_range.overlap?(new_address_range)

          raise OverlappingMemoryError, format("Memory %s (at 0x%04x-0x%04x) overlaps with 0x%04x-0x%04x",
            attached_memory.memory.name,
            attached_memory.address_range.first, attached_memory.address_range.last,
            new_address_range.first, new_address_range.last)
        end

        attached_memories.push(AttachedMemory.new(memory, new_address_range))

        self
      end

      sig { params(address: Integer).returns(MemoryByte).override }
      def [](address)
        attached_memory = attached_memories.find { |attached_memory| attached_memory.address_range.cover?(address) }

        raise UnattachedMemoryError, format("Address 0x%04x is not attached", address) unless attached_memory

        attached_memory.memory[address - attached_memory.address_range.first]
      end
    end
  end
end
