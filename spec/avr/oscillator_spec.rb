# typed: false

require "benchmark"

RSpec.describe(AVR::Oscillator) do
  let(:oscillator) { described_class.new }
  let(:named_oscillator) { described_class.new("foo") }
  let(:clock) { AVR::Clock.new }

  it "is defined and is a subclass of AVR::Clock" do
    expect(described_class).to(be_an_instance_of(Class))
    expect(described_class.superclass).to(eq(AVR::Clock))
  end

  it "can be initialized with no arguments" do
    expect(oscillator).to(be_an_instance_of(described_class))
  end

  it "can be initialized with a name argument" do
    expect(named_oscillator).to(be_an_instance_of(described_class))
    expect(named_oscillator.name).to(eql("foo"))
  end

  it "can tick" do
    oscillator.tick

    expect(oscillator.ticks).to(be(1))
  end

  it "can be attached to and drive a clock" do
    oscillator.push_sink(clock)
    oscillator.run(5.times)

    expect(oscillator.ticks).to(be(5))
    expect(clock.ticks).to(be(5))
  end

  describe "#run" do
    it "ticks based on an enumerator" do
      oscillator.run(5.times)

      expect(oscillator.ticks).to(be(5))
    end

    it "returns the number of times ticked" do
      oscillator.tick

      expect(oscillator.run(5.times)).to(be(5))
      expect(oscillator.ticks).to(be(6))
    end
  end

  describe "#run_timed" do
    it "ticks for the expected amount of time" do
      elapsed_time = Benchmark.realtime { oscillator.run_timed(0.1) }

      # Give a 25% margin here, to try and avoid flakes.
      expect(elapsed_time).to(be > 0.075)
      expect(elapsed_time).to(be < 0.125)
    end
  end
end
