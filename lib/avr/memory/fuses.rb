# typed: true
# frozen_string_literal: true

module AVR
  class Memory
    class Fuses < MemoryByteBacked
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

          setup_named_bits_methods(reg, bit_names)
          setup_multi_bit_fuse_extractors(reg, bit_names)
        end

        reset_to_defaults
      end

      sig { params(values: T::Array[Integer]).void }
      def set(values)
        values.each_with_index do |value, address|
          byte = memory[address]
          byte.value = value if byte
        end
        device.cpu.reset if @device.instance_variable_defined?(:@fuses) && @device.instance_variable_get(:@fuses)
      end

      sig { void }
      def reset_to_defaults
        set(device.fuse_default_values.values)
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

      private

      sig { params(reg: MemoryByteRegister, bit_names: T.nilable(T::Array[T.nilable(Symbol)])).void }
      def setup_named_bits_methods(reg, bit_names)
        return unless bit_names

        bit_names.compact.each do |bit_name|
          define_singleton_method(:"#{bit_name}?") { !reg.send(bit_name) }
          define_singleton_method(:"#{bit_name.to_s.downcase}?") { !reg.send(bit_name) }
        end
      end

      sig { params(reg: MemoryByteRegister, bit_names: T.nilable(T::Array[T.nilable(Symbol)])).void }
      def setup_multi_bit_fuse_extractors(reg, bit_names)
        return unless bit_names

        multi_bit_fuses = {}
        bit_names.compact.each do |bit_name|
          next unless (match = bit_name.to_s.match(/\A(.+?)(\d+)\z/))

          prefix = match[1]
          index = match[2].to_i
          multi_bit_fuses[prefix] ||= {}
          multi_bit_fuses[prefix][index] = bit_name
        end

        multi_bit_fuses.each do |prefix, bits_map|
          count = bits_map.length
          next unless count > 1 && bits_map.keys.sort == (0...count).to_a

          ordered_bits = (0...count).map { |i| bits_map[i] }
          extractor = proc do
            ordered_bits.each_with_index.reduce(0) do |val, (bit_name, idx)|
              val | ((reg.send(bit_name) ? 1 : 0) << idx)
            end
          end

          define_singleton_method(prefix.to_sym, &extractor)
          define_singleton_method(prefix.downcase.to_sym, &extractor)
          reg.define_singleton_method(prefix.to_sym, &extractor)
          reg.define_singleton_method(prefix.downcase.to_sym, &extractor)
        end
      end
    end
  end
end