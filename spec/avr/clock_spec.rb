# typed: false

RSpec.describe(AVR::Clock) do
  let(:clock) { described_class.new }
  let(:other_clock) { described_class.new }
  let(:named_clock) { described_class.new("foo") }

  it "is defined" do
    expect(described_class).to(be_an_instance_of(Class))
  end

  it "can be initialized with no arguments" do
    expect(clock).to(be_an_instance_of(described_class))
  end

  it "can be initialized with a name argument" do
    expect(named_clock).to(be_an_instance_of(described_class))
    expect(named_clock.name).to(eql("foo"))
  end

  it "can tick" do
    clock.tick
    expect(clock.ticks).to(be(1))
  end

  it "can push a sink" do
    clock.push_sink(AVR::Clock::Sink.new {})
    expect(clock.sinks.size).to(be(1))
  end

  it "can unshift a sink" do
    clock.unshift_sink(AVR::Clock::Sink.new {})
    expect(clock.sinks.size).to(be(1))
  end

  it "calls its sinks" do
    v = false
    s = AVR::Clock::Sink.new { v = true }

    clock.push_sink(s)
    expect(v).to(be(false))
    clock.tick
    expect(v).to(be(true))
  end

  it "calls its sinks in the correct order when pushed" do
    call_order = []
    clock.push_sink(AVR::Clock::Sink.new { call_order << 1 })
    clock.push_sink(AVR::Clock::Sink.new { call_order << 2 })

    clock.tick
    expect(call_order).to(eql([1, 2]))

    clock.clear_sinks

    call_order = []
    clock.push_sink(AVR::Clock::Sink.new { call_order << 2 })
    clock.push_sink(AVR::Clock::Sink.new { call_order << 1 })

    clock.tick
    expect(call_order).to(eql([2, 1]))
  end

  it "calls its sinks in the correct order when unshifted" do
    call_order = []
    clock.unshift_sink(AVR::Clock::Sink.new { call_order << 1 })
    clock.unshift_sink(AVR::Clock::Sink.new { call_order << 2 })

    clock.tick
    expect(call_order).to(eql([2, 1]))

    clock.clear_sinks

    call_order = []
    clock.unshift_sink(AVR::Clock::Sink.new { call_order << 2 })
    clock.unshift_sink(AVR::Clock::Sink.new { call_order << 1 })

    clock.tick
    expect(call_order).to(eql([1, 2]))
  end

  it "can be attached to and drive another Clock" do
    clock.push_sink(other_clock)

    expect(clock.ticks).to(be(0))
    expect(other_clock.ticks).to(be(0))

    clock.tick

    expect(clock.ticks).to(be(1))
    expect(other_clock.ticks).to(be(1))
  end
end
