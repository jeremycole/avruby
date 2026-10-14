# typed: true
# frozen_string_literal: true

module AVR
  class Fuses < Memory
    extend T::Sig

    DEFAULT_VALUE = 0xff

    sig { returns(Device) }
    attr_reader :device

    sig { returns(RegisterFile) }
    attr_reader :registers

    sig { params(device: Device).void }
    def initialize(device)
      super("Fuses", device.fuse_size, DEFAULT_VALUE)
      @device = device
      @registers = RegisterFile.new(device.cpu)

      device.fuse_memory_map.each do |name, address|
        bit_names = device.fuse_bit_names_map[name]
        memory_byte = T.must(memory[address])

        reg = if bit_names
                MemoryByteRegisterWithNamedBits.new(device.cpu, name.to_s, memory_byte, bit_names)
              else
                MemoryByteRegister.new(device.cpu, name.to_s, memory_byte)
              end

        @registers.add(reg)

        define_singleton_method(name) { reg }
        define_singleton_method(:"#{name}=") { |value| reg.value = value }
        define_singleton_method(name.to_s.downcase.to_sym) { reg }
        define_singleton_method(:"#{name.to_s.downcase}=") { |value| reg.value = value }
      end

      reset
    end

    sig { void }
    def reset
      super
      device.fuse_default_values.each do |name, default_val|
        addr = device.fuse_memory_map[name]
        T.must(memory[addr]).value = default_val if addr
      end
    end

    def [](key)
      case key
      when Integer
        memory[key]
      when Symbol, String
        @registers.registers[key.to_s] || @registers.registers[key.to_s.upcase]
      end
    end

    def print_status
      registers.print_status
    end

    def inspect
      "#<#{self.class.name} #{registers.register_values}>"
    end
  end
end
