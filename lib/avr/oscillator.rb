# typed: true
# frozen_string_literal: true

module AVR
  class Oscillator < Clock
    def infinite
      [true].cycle
    end

    def time_limit(limit)
      Enumerator.new do |y|
        end_time = Time.now.to_f + limit
        y << true while Time.now.to_f < end_time
      end
    end

    def run(limit = infinite)
      start_ticks = ticks
      limit.each { tick }
      ticks - start_ticks
    end

    def run_timed(time)
      run(time_limit(time))
    end
  end
end
