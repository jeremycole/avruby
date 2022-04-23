# typed: strict
# frozen_string_literal: true

require "avr/memory/memory_byte"
require "intel_hex"

module AVR
  class Memory
    extend T::Sig
    extend T::Helpers
    abstract!

    class Watch
      extend T::Sig

      sig do
        params(
          proc: T.nilable(
            T.proc.params(
              memory_byte: MemoryByte,
              old_value: Integer,
              new_value: Integer,
            ).void
          ),
          block: T.nilable(
            T.proc.params(
              memory_byte: MemoryByte,
              old_value: Integer,
              new_value: Integer,
            ).void
          )
        ).void
      end
      def initialize(proc = nil, &block)
        @watch_proc = T.let(proc || T.must(block).to_proc, Proc)
      end

      sig { params(memory_byte: MemoryByte, old_value: Integer, new_value: Integer).void }
      def notify(memory_byte, old_value, new_value)
        @watch_proc.call(memory_byte, old_value, new_value)
      end
    end

    class WatchBinding
      extend T::Sig

      sig { returns(Watch) }
      attr_reader :watch

      sig { returns(T.nilable(T::Array[Integer])) }
      attr_reader :filter

      sig { params(watch: Watch, filter: T.nilable(T::Array[Integer])).void }
      def initialize(watch, filter = nil)
        @watch = watch
        @filter = filter
      end

      sig { params(address: Integer).returns(T::Boolean) }
      def include?(address)
        if filter
          return true if filter&.include?(address)

          false
        end
        true
      end
    end

    sig { returns(String) }
    attr_reader :name

    sig { returns(Integer) }
    attr_reader :size

    sig { returns(T::Array[MemoryByte]) }
    attr_reader :memory

    sig { returns(T::Array[WatchBinding]) }
    attr_reader :watches

    sig { params(name: String, size: Integer, value: Integer).void }
    def initialize(name, size, value = 0)
      @name = name
      @size = size
      @memory = T.let(
        size.times.map { |address| MemoryByte.new(self, address, value) },
        T::Array[MemoryByte]
      )
      @watches = T.let([], T::Array[WatchBinding])
    end

    sig { returns(String) }
    def inspect
      "#<#{self.class.name} size=#{size}>"
    end

    sig { void }
    def reset
      memory.each do |byte|
        byte.value = 0
      end
    end

    sig { params(memory_byte: MemoryByte, old_value: Integer, new_value: Integer).void }
    def notify(memory_byte, old_value, new_value)
      watches.each do |watch|
        if watch.include?(memory_byte.address)
          watch.watch.notify(memory_byte, old_value, new_value)
        end
      end
    end

    sig { params(watch: Watch, filter: T.nilable(T::Array[Integer])).void }
    def unshift_watch(watch, filter = nil)
      watches.unshift(WatchBinding.new(watch, filter))
    end

    sig { params(watch: Watch, filter: T.nilable(T::Array[Integer])).void }
    def push_watch(watch, filter = nil)
      watches.push(WatchBinding.new(watch, filter))
    end

    sig do
      params(
        filter: T.untyped,
        block: T.proc.params(
          memory_byte: MemoryByte,
          old_value: Integer,
          new_value: Integer,
        ).void
      ).returns(Watch)
    end
    def watch(filter = nil, &block)
      watch = Watch.new(block.to_proc)
      push_watch(watch, filter.is_a?(Integer) ? [filter] : filter)
      watch
    end

    sig { params(address: Integer).returns(Integer) }
    def word(address)
      byte_address = address << 1
      (T.must(memory[byte_address + 1]).value << 8) | T.must(memory[byte_address]).value
    end

    sig { params(address: Integer, value: Integer).void }
    def set_word(address, value)
      byte_address = address << 1
      T.must(memory[byte_address + 1]).value = (value & 0xff00) >> 8
      T.must(memory[byte_address]).value = value & 0x00ff
    end

    sig { params(filename: String).returns(Integer) }
    def load_from_intel_hex(filename)
      ihex = IntelHex::FileReader.new(filename)
      sum = 0
      ihex.each_byte_with_address do |byte, address|
        T.must(memory[address]).value = byte
        sum += 1
      end
      sum
    end
  end
end
