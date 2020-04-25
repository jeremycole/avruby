# frozen_string_literal: true

module AVR
  class Clock
    class Sink
      def initialize(name, sink_proc = nil, &block)
        @name = name
        @sink_proc = sink_proc || block.to_proc
      end

      def tick(source, ticks)
        @sink_proc.call(source, ticks)
      end
    end

    attr_reader :name
    attr_reader :sinks
    attr_reader :watches
    attr_accessor :count
    attr_accessor :ticks
    attr_accessor :scale

    def initialize(name)
      @name = name
      @sinks = []
      @watches = {}
      @ticks = 0
      @count = 0
      @scale = 1
    end

    def unshift_sink(sink)
      sinks.unshift(sink)
    end

    def push_sink(sink)
      sinks.push(sink)
    end

    def notify_at_tick(tick, sink)
      @watches[tick] ||= []
      @watches[tick] << sink
    end

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
