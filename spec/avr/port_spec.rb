# typed: false
# frozen_string_literal: true

RSpec.describe(AVR::Port) do
  let(:device) { AVR::Device::Atmel_ATmega328p.new }
  let(:cpu) { device.cpu }
  subject(:port_b) { cpu.ports[:B] }

  it "exposes cpu, name, pin, ddr, and port memory bytes" do
    expect(port_b.cpu).to(eq(cpu))
    expect(port_b.name).to(eq(:B))
    expect(port_b.pin).to(eq(cpu.PINB.memory_byte))
    expect(port_b.ddr).to(eq(cpu.DDRB.memory_byte))
    expect(port_b.port).to(eq(cpu.PORTB.memory_byte))
  end

  it "defaults pins to high impedance (:Z) when configured as inputs" do
    cpu.DDRB.value = 0x00
    expect(port_b.pin_states).to(eq([:Z] * 8))
    expect(port_b.value).to(eq(0x00))
  end

  it "reflects PORT output values when DDR bits are configured as outputs" do
    cpu.DDRB.value = 0x03 # pins 0 and 1 as output
    cpu.PORTB.value = 0x01 # pin 0 high, pin 1 low

    expect(port_b.pin_state(0, 0, 0x03, 0x01)).to(eq(:H))
    expect(port_b.pin_state(1, 0, 0x03, 0x01)).to(eq(:L))
    expect(port_b.pin_state(2, 0, 0x03, 0x01)).to(eq(:Z))

    expect(port_b.pin_states[0..2]).to(eq([:H, :L, :Z]))
    expect(port_b.value).to(eq(0x01))
  end

  it "allows setting input pin state with pin_input" do
    cpu.DDRB.value = 0x00 # input
    port_b.pin_input(0, :H)
    port_b.pin_input(1, :L)

    expect(port_b.pin_states[0]).to(eq(:H))
    expect(port_b.pin_states[1]).to(eq(:L))
    expect(port_b.pin_states[2]).to(eq(:Z))
    expect(port_b.value).to(eq(0x01))
  end

  it "raises error on invalid pin state" do
    expect do
      port_b.pin_input(0, :INVALID)
    end.to(raise_error(RuntimeError))
  end

  it "formats value_pins and inspect" do
    cpu.DDRB.value = 0x01
    cpu.PORTB.value = 0x01
    expect(port_b.value_pins).to(eq("0=H, 1=Z, 2=Z, 3=Z, 4=Z, 5=Z, 6=Z, 7=Z"))
    expect(port_b.inspect).to(eq("#<AVR::Port 0=H, 1=Z, 2=Z, 3=Z, 4=Z, 5=Z, 6=Z, 7=Z>"))
  end
end
