# typed: true
# frozen_string_literal: true

module AVR
  class RegisterFile
    def add(register)
      @registers[register.name] = register
      @cpu.send(:define_singleton_method, register.name.to_sym, proc { register })
      @cpu.send(:define_singleton_method, (register.name.to_s + '=').to_sym, proc { |value| register.value = value })
      @register_list << register.name
      return unless register.is_a?(RegisterPair)

      @word_register_map[register.l] = register
      @word_register_map[register.h] = register
    end

    attr_reader :registers
    attr_reader :word_register_map

    def initialize(cpu)
      @cpu = cpu
      @registers = {}
      @word_register_map = {}
      @register_list = []
    end

    def reset
      @registers.each_value do |register|
        register.value = 0
      end
    end

    def register_values
      @register_list.map { |name| @registers[name].to_s }.join(', ')
    end

    def print_status
      @register_list.each_slice(8) do |slice|
        puts slice.map { |name| '%10s' % ["#{name}=#{@registers[name].value_hex}"] }.join + '\n'
      end
    end

    def fetch(key)
      @registers.fetch(@register_list.fetch(key)) if key.is_a?(Integer)
    end

    def [](key)
      @registers[@register_list[key]] if key.is_a?(Integer)
    end

    def associated_word_register(register)
      @word_register_map[register]
    end

    def inspect
      "#<#{self.class.name} #{register_values}>"
    end
  end
end
