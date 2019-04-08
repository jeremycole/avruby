module AVR
  class Oscillator < Clock
    def infinite
      Enumerator.new do |y|
        loop do
          y << true
        end
      end
    end

    def time_limit(limit)
      Enumerator.new do |y|
        end_time = Time.now.to_f + limit
        while Time.now.to_f < end_time
           y << true
        end
      end
    end

    def run(limit=infinite)
      limit.each { tick }
    end

    def run_timed(time)
      run(time_limit(time))
    end
  end
end