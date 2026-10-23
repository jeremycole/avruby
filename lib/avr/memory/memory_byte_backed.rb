# typed: strict
# frozen_string_literal: true

module AVR
  class Memory
    class MemoryByteBacked < Memory
      extend T::Sig

      sig { returns(T::Array[MemoryByte]) }
      attr_reader :memory

      sig { returns(T::Array[WatchBinding]) }
      attr_reader :watches

      class Watch
        extend T::Sig

        WatchCallback = T.type_alias do
          T.nilable(
            T.proc.params(
              memory_byte: MemoryByte,
              old_value: Integer,
              new_value: Integer,
            ).void
          )
        end

        sig do
          params(
            proc: WatchCallback,
            block: WatchCallback
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

            return false
          end
          true
        end
      end

      sig { params(name: String, size: Integer, value: Integer).void }
      def initialize(name, size, value = 0)
        super(name, size)

        @memory = T.let(
          size.times.map { |address| MemoryByte.new(self, address, value) },
          T::Array[MemoryByte]
        )
        @watches = T.let([], T::Array[WatchBinding])
      end

      sig { params(address: Integer).returns(MemoryByte).override }
      def [](address)
        memory.fetch(address)
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
          watch.watch.notify(memory_byte, old_value, new_value) if watch.include?(memory_byte.address)
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
    end
  end
end
