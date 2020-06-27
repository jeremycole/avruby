# typed: strict
# frozen_string_literal: true

module AVR
  class Oscillator < Clock
    extend T::Sig

    sig { returns(T::Enumerator[TrueClass]) }
    def infinite
      [true].cycle
    end

    sig { params(time: T.any(Float, Integer)).returns(T::Enumerator[T.untyped]) }
    def time_limit(time)
      Enumerator.new do |y|
        end_time = Time.now.to_f + time
        y << true while Time.now.to_f < end_time
      end
    end

    sig { params(limit: T::Enumerator[T.untyped]).returns(Integer) }
    def run(limit = infinite)
      start_ticks = ticks
      limit.each { tick }
      ticks - start_ticks
    end

    sig { params(time: T.any(Float, Integer)).returns(Integer) }
    def run_timed(time)
      run(time_limit(time))
    end
  end
end
