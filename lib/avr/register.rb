module AVR
  class Register
    attr_reader :cpu
    attr_reader :name
    attr_reader :value

    def initialize(cpu, name)
      @cpu = cpu
      @name = name
    end

    def to_i
      value.to_i
    end

    def to_s
      name + "=" + value.to_s
    end

    def inspect
      "#<#{self.class.name} #{to_s}>"
    end
  end
end

require "avr/register/memory_byte_register"
require "avr/register/register_pair"
require "avr/register/lower_register"
require "avr/register/upper_register"
require "avr/register/register_file"
require "avr/register/sreg"
require "avr/register/sp"