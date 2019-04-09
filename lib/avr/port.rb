module AVR
  class Port
    PINS = (0..7).to_a.freeze
    attr_reader :cpu
    attr_reader :name

    def initialize(cpu, name, pin_address, ddr_address, port_address)
      @cpu = cpu
      @name = name
      @input = PINS.map { :Z }
      @pin_address = pin_address
      @ddr_address = ddr_address
      @port_address = port_address
      @sram_watch = AVR::Memory::Watch.new do |memory_byte, old_value, new_value|
        puts "Port watch fired"
      end
      @cpu.sram.push_watch([@ddr_address, @port_address], @sram_watch)
    end

    def pin
      cpu.sram.memory[@pin_address]
    end

    def ddr
      cpu.sram.memory[@ddr_address]
    end

    def port
      cpu.sram.memory[@port_address]
    end

    def pin_input(n, state)
      raise unless [:H, :L, :Z].include?(state)
      @input[n] = state
    end

    def pin_state(n, pin_value, ddr_value, port_value)
      n_bv = 1 << n
      drive = (ddr_value & n_bv) == n_bv
      state = (port_value & n_bv) == n_bv
      drive ? (state ? :H : :L) : @input[n]
    end

    def pin_states
      pin_value = pin.value
      ddr_value = ddr.value
      port_value = port.value

      PINS.map { |n| pin_state(n, pin_value, ddr_value, port_value) }
    end

    def value_pins
      PINS.zip(pin_states).map { |n, s| "P#{n}=#{s}" }.join(", ")
    end

    def value
      sum = 0
      pin_states.each_with_index { |n, i| sum += ((n==:H) ? 1 : 0) * 2**i }
      sum
    end

    def inspect
      "#<#{self.class.name} #{value_pins}>"
    end
  end
end