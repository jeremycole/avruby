#!/usr/bin/env ruby

require "avr"

EXECUTION_TIME = 10.0
device = AVR::Device::Atmel_ATmega328p.new
device.flash.load_from_intel_hex("test/blink/blink.hex")
device.oscillator.run_timed(EXECUTION_TIME)

puts "Execution speed: %.2f kHz" % [
  device.oscillator.ticks.to_f / EXECUTION_TIME / 1000.0
]