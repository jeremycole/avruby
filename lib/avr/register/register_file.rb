module AVR
  class RegisterFile
    def add(register)
      @registers[register.name] = register
      @cpu.send(:define_singleton_method, register.name.to_sym, proc { register })
      @cpu.send(:define_singleton_method, (register.name.to_s + "=").to_sym, proc { |value| register.value = value })
      @register_list << register.name
      if register.is_a?(RegisterPair)
        @word_register_map[register.l] = register
        @word_register_map[register.h] = register
      end
    end

    attr_reader :registers
    attr_reader :word_register_map

    def initialize(cpu)
      @cpu = cpu
      @registers = Hash.new
      @word_register_map = Hash.new
      @register_list = []
    end

    def reset
      @registers.each_value do |register|
        register.value = 0
      end
    end

    def register_values
      @register_list.map { |name| @registers[name].to_s }.join(", ")
    end

    def print_status
      @register_list.each_slice(8) do |slice|
        puts slice.map { |name| "%10s" % [name + "=" + @registers[name].value_hex] }.join + "\n"
      end
    end

    def [](key)
      @registers[@register_list[key]] if key.is_a?(Fixnum)
    end

    def associated_word_register(register)
      @word_register_map[register]
    end

    def inspect
      "#<#{self.class.name} #{register_values}>"
    end
  end
end