#!/usr/bin/env ruby

require "avr"

hex_file = "test/blink/blink.hex"
tick_count = 100

print "Initializing device... "
device = AVR::Device::Atmel_ATmega328p.new
puts "OK."

print "Loading #{hex_file} into Flash... "
bytes_loaded = device.flash.load_from_intel_hex(hex_file)
puts "OK. Loaded #{bytes_loaded} bytes."

print "Setting up tracing... "

device.cpu.trace do |instruction|
  puts "Executing instruction:"
  puts "  " + instruction.to_s
end

device.oscillator.unshift_sink(AVR::Clock::Sink.new("pre-execution status") {
  puts
  puts
  puts "PRE-EXECUTION STATUS"
  puts "********************"
  device.cpu.print_status
})

device.oscillator.push_sink(AVR::Clock::Sink.new("post-execution status") {
  puts
  puts "POST-EXECUTION STATUS"
  puts "*********************"
  device.cpu.print_status
})

device.cpu.sram.watch do |memory_byte, old_value, new_value|
  puts "*** MEMORY TRACE: %s[%04x]: %02x -> %02x ***" % [
    memory_byte.memory.name,
    memory_byte.address,
    old_value,
    new_value,
  ]
end

puts "OK."

puts "Starting oscillator for #{tick_count} ticks..."
device.oscillator.run(tick_count.times)

puts "Stopped."