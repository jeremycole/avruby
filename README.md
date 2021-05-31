# AVRuby

[![rspec test status](https://github.com/jeremycole/avruby/actions/workflows/rspec.yml/badge.svg)](https://github.com/jeremycole/avruby/actions/workflows/rspec.yml)
[![rubocop style check status](https://github.com/jeremycole/avruby/actions/workflows/rubocop.yml/badge.svg)](https://github.com/jeremycole/avruby/actions/workflows/rubocop.yml)
[![sorbet type check status](https://github.com/jeremycole/avruby/actions/workflows/sorbet.yml/badge.svg)](https://github.com/jeremycole/avruby/actions/workflows/sorbet.yml)

## tl;dr

This is an AVR emulator, written really stupidly in Ruby. It's not supposed to be practical, it's supposed to be educational, and maybe a bit of fun.

## Status

I initially started this as an exercise in parsing some opcodes, as I was learning how the AVR instruction set worked while learning AVR assembly. Once I could parse a few things, I thought "Hey, I could execute these in Ruby – haha!" and AVRuby was born.

The CPU is nearly fully implemented. SRAM, Flash, and EEPROM memories are supported. Most opcodes work. Support for loading the flash (or any memory) from Intel hex is supported, so it's easy to load existing code. Basic RSpec tests are implemented for opcodes and some other things. Most peripherals are not implemented. Contributions (or insults) are welcome.

Currently, many simple programs (such as blink) will run out of the box, although the CPU as emulated is exceedingly slow. It runs at ~140 kHz on a MacBook Pro with 2.8 GHz Intel Core i7 using Ruby 2.6.3.

# It's fun.
