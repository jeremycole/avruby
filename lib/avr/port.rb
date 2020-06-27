# typed: strict
# frozen_string_literal: true

module AVR
  class Port
    extend T::Sig

    PINS = T.let((0..7).to_a.freeze, T::Array[Integer])

    sig { returns(CPU) }
    attr_reader :cpu

    sig { returns(T.any(Symbol, String)) }
    attr_reader :name

    sig do
      params(
        cpu: CPU,
        name: T.any(Symbol, String),
        pin_address: Integer,
        ddr_address: Integer,
        port_address: Integer
      ).void
    end
    def initialize(cpu, name, pin_address, ddr_address, port_address)
      @cpu = cpu
      @name = name
      @input = T.let(PINS.map { :Z }, T::Array[Symbol])
      @pin_address = pin_address
      @ddr_address = ddr_address
      @port_address = port_address
      @sram_watch = T.let(
        Memory::Watch.new do |_memory_byte, _old_value, _new_value|
          # puts "Port watch fired"
        end,
        Memory::Watch
      )
      @cpu.sram.push_watch(@sram_watch, [@ddr_address, @port_address])
    end

    sig { returns(MemoryByte) }
    def pin
      T.must(cpu.sram.memory[@pin_address])
    end

    sig { returns(MemoryByte) }
    def ddr
      T.must(cpu.sram.memory[@ddr_address])
    end

    sig { returns(MemoryByte) }
    def port
      T.must(cpu.sram.memory[@port_address])
    end

    sig { params(pin: Integer, state: Symbol).returns(Symbol) }
    def pin_input(pin, state)
      raise unless %i[H L Z].include?(state)

      @input[pin] = state
    end

    sig do
      params(
        pin: Integer,
        _pin_value: Integer,
        ddr_value: Integer,
        port_value: Integer
      ).returns(Symbol)
    end
    def pin_state(pin, _pin_value, ddr_value, port_value)
      n_bv = 1 << pin
      drive = (ddr_value & n_bv) == n_bv
      state = (port_value & n_bv) == n_bv

      return (state ? :H : :L) if drive

      @input.fetch(pin)
    end

    sig { returns(T::Array[Symbol]) }
    def pin_states
      pin_value = pin.value
      ddr_value = ddr.value
      port_value = port.value

      PINS.map { |n| pin_state(n, pin_value, ddr_value, port_value) }
    end

    sig { returns(String) }
    def value_pins
      PINS.zip(pin_states).map { |n, s| "P#{n}=#{s}" }.join(', ')
    end

    sig { returns(Integer) }
    def value
      sum = 0
      pin_states.each_with_index { |n, i| sum += (n == :H ? 1 : 0) * (2**i).to_i }
      sum
    end

    sig { returns(String) }
    def inspect
      "#<#{self.class.name} #{value_pins}>"
    end
  end
end
