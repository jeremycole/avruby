#!/usr/bin/env ruby

require "avr"
require "irb"

tick_count = 100

print "Initializing device... "
@device = AVR::Device::Atmel_ATmega328p.new
puts "OK."

puts "Loading firmware..."
ARGV.each do |hex_file|
  print "Loading #{hex_file} into Flash... "
  bytes_loaded = @device.flash.load_from_intel_hex(hex_file)
  puts "OK. Loaded #{bytes_loaded} bytes."
end
ARGV.size.times { ARGV.shift }

print "Setting up tracing... "
@device.trace_all
puts "OK."

IRB.start

puts "Stopped."
