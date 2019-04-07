module AVR
  class RegisterFile
    def add(register)
      @registers[register.name] = register
      @cpu.class.send(:define_method, register.name.to_sym, proc { register })
      @cpu.class.send(:define_method, (register.name.to_s + "=").to_sym, proc { |value| register.value = value })
      @register_list << register.name
    end

    def initialize(cpu)
      @cpu = cpu
      @registers = Hash.new
      @register_list = []
    end

    def register_values
      @register_list.map { |name| @registers[name].to_s }.join(", ")
    end

    def [](key)
      @registers[@register_list[key]] if key.is_a?(Fixnum)
    end

    def inspect
      "#<#{self.class.name} #{register_values}>"
    end
  end
end