device = AVR::Device::Atmel_ATmega328p.new
device.flash.load_from_intel_hex("/Users/jeremycole/git/asmvr/blink.hex")

device.cpu.trace { |i| puts i }

device.oscillator.unshift_sink(AVR::Clock::Sink.new("status") {
  device.cpu.print_status
})

device.oscillator.tick