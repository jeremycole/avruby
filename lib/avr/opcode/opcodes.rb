# typed: strict
# frozen_string_literal: true

require 'avr/opcode/operand_parsers'
require 'avr/opcode/nop'
require 'avr/opcode/break'
require 'avr/opcode/sleep'
require 'avr/opcode/wdr'
require 'avr/opcode/sreg'
require 'avr/opcode/register'
require 'avr/opcode/compare'
require 'avr/opcode/data/stack'
require 'avr/opcode/data/immediate'
require 'avr/opcode/data/program'
require 'avr/opcode/data/sram'
require 'avr/opcode/branch/unconditional'
require 'avr/opcode/branch/conditional'
require 'avr/opcode/branch/return'
require 'avr/opcode/math/addition'
require 'avr/opcode/math/subtraction'
require 'avr/opcode/math/multiplication'
require 'avr/opcode/math/bitwise'
require 'avr/opcode/io/bit'
require 'avr/opcode/io/in_out'
