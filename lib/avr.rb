# typed: strict
# frozen_string_literal: true

require 'sorbet-runtime'
if ENV.include?('SORBET_DEFAULT_CHECKED_LEVEL')
  level = ENV.fetch('SORBET_DEFAULT_CHECKED_LEVEL').to_sym
  puts "Setting Sorbet default_checked_level to :#{level}!"
  puts

  T::Configuration.default_checked_level = level
end

require 'avr/version'
require 'avr/value'
require 'avr/memory'
require 'avr/memory/sram'
require 'avr/memory/eeprom'
require 'avr/memory/flash'
require 'avr/register'
require 'avr/register_with_bit_number'
require 'avr/register_with_displacement'
require 'avr/register_with_modification'
require 'avr/register/memory_byte_register'
require 'avr/register/memory_byte_register_with_named_bits'
require 'avr/register_with_named_bit'
require 'avr/register/register_pair'
require 'avr/register/register_file'
require 'avr/register/sreg'
require 'avr/register/sp'
require 'avr/argument'
require 'avr/cpu'
require 'avr/opcode_decoder'
require 'avr/opcode'
require 'avr/instruction'
require 'avr/opcode/opcodes'
require 'avr/clock'
require 'avr/oscillator'
require 'avr/device'
require 'avr/port'

require 'avr/device/atmel_atmega328p'
