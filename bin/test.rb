device = AVR::Device::Atmel_ATmega328p.new
device.flash.load_from_intel_hex("/Users/jeremycole/git/asmvr/blink.hex")

device.cpu.trace do |instruction|
  puts "Executing instruction:"
  puts "  " + instruction.to_s
end

device.oscillator.unshift_sink(AVR::Clock::Sink.new("status") {
  device.cpu.print_status
})

device.cpu.sram.watch do |memory_byte, old_value, new_value|
  puts "%s[%04x]: %02x -> %02x" % [
    memory_byte.memory.name,
    memory_byte.address,
    old_value,
    new_value,
  ]
end

device.oscillator.tick