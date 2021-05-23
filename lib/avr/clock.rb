# typed: strict
# frozen_string_literal: true

module AVR
  class Clock
    extend T::Sig

    class Sink
      extend T::Sig

      sig do
        params(
          name: T.nilable(String),
          sink_proc: T.nilable(T.proc.params(source: Clock, ticks: Integer).void),
          block: T.nilable(T.proc.params(source: Clock, ticks: Integer).void)
        ).void
      end
      def initialize(name = nil, sink_proc = nil, &block)
        raise unless sink_proc || block_given?
        @name = name
        @sink_proc = T.let(
          sink_proc || block.to_proc,
          T.nilable(T.proc.params(source: Clock, ticks: Integer).void)
        )
      end

      sig { params(source: Clock, ticks: Integer).void }
      def tick(source, ticks)
        T.must(@sink_proc).call(source, ticks)
      end
    end

    sig { returns(T.nilable(String)) }
    attr_reader :name

    sig { returns(T::Array[T.any(Clock, Sink)]) }
    attr_reader :sinks

    sig { returns(T::Hash[Integer, T.untyped]) }
    attr_reader :watches

    sig { returns(Integer) }
    attr_accessor :count

    sig { returns(Integer) }
    attr_accessor :ticks

    sig { returns(Integer) }
    attr_accessor :scale

    sig { params(name: T.nilable(String)).void }
    def initialize(name = nil)
      @name = name
      @sinks = T.let([], T::Array[Sink])
      @watches = T.let({}, T::Hash[Integer, T.untyped])
      @ticks = T.let(0, Integer)
      @count = T.let(0, Integer)
      @scale = T.let(1, Integer)
      @last_tick = T.let(0, Integer)
    end

    sig { params(sink: Sink).void }
    def unshift_sink(sink)
      sinks.unshift(sink)
    end

    sig { params(sink: T.any(Clock, Sink)).void }
    def push_sink(sink)
      sinks.push(sink)
    end

    sig { void }
    def clear_sinks
      @sinks = []
    end

    sig { params(tick: Integer, sink: Sink).void }
    def notify_at_tick(tick, sink)
      @watches[tick] ||= []
      @watches[tick] << sink
    end

    sig { params(_source: T.nilable(Clock), _ticks: T.nilable(Integer)).returns(Integer) }
    def tick(_source = nil, _ticks = nil)
      @count += 1
      if (@count % @scale).zero?
        @last_tick = @ticks
        sinks.each do |sink|
          sink.tick(self, @ticks)
        end
        watches[@ticks]&.each do |watch|
          watch.tick(self, @ticks)
        end
        @ticks += 1
      end
      @last_tick
    end
  end
end
