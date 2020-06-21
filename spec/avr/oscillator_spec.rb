require 'benchmark'

RSpec.describe AVR::Oscillator do
  let(:oscillator) { AVR::Oscillator.new }
  let(:named_oscillator) { AVR::Oscillator.new('foo') }
  let(:clock) { AVR::Clock.new }

  it 'is defined and is a subclass of AVR::Clock' do
    expect(AVR::Oscillator).to be_an_instance_of Class
    expect(AVR::Oscillator.superclass).to eq AVR::Clock
  end

  it 'can be initialized with no arguments' do
    expect(oscillator).to be_an_instance_of AVR::Oscillator
  end

  it 'can be initialized with a name argument' do
    expect(named_oscillator).to be_an_instance_of AVR::Oscillator
    expect(named_oscillator.name).to eql 'foo'
  end

  it 'can tick' do
    oscillator.tick

    expect(oscillator.ticks).to eql 1
  end

  it 'can be attached to and drive a clock' do
    oscillator.push_sink(clock)
    oscillator.run(5.times)

    expect(oscillator.ticks).to eql 5
    expect(clock.ticks).to eql 5
  end

  describe '#run' do
    it 'ticks based on an enumerator' do
      oscillator.run(5.times)

      expect(oscillator.ticks).to eql 5
    end

    it 'returns the number of times ticked' do
      oscillator.tick

      expect(oscillator.run(5.times)).to eql 5
      expect(oscillator.ticks).to eql 6
    end
  end

  describe '#run_timed' do
    it 'ticks for the expected amount of time' do
      elapsed_time = Benchmark.realtime { oscillator.run_timed(0.1) }

      # Give a 25% margin here, to try and avoid flakes.
      expect(elapsed_time).to be > 0.075
      expect(elapsed_time).to be < 0.125
    end
  end
end