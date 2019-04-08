module AVR
  class Clock
    class Sink
      def initialize(name, &block)
        @name = name
        @sink_proc = block.to_proc
      end

      def tick(source, ticks)
        @sink_proc.call(source, ticks)
      end
    end

    attr_reader :name
    attr_reader :sinks
    attr_accessor :count
    attr_accessor :ticks
    attr_accessor :scale

    def initialize(name)
      @name = name
      @sinks = []
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

    def tick(source=nil, ticks=nil)
      @count += 1
      if (@count % @scale) == 0
        @last_tick = @ticks
        sinks.each do |sink|
          sink.tick(self, @ticks)
        end
        @ticks += 1
      end
      @last_tick
    end
  end
end
